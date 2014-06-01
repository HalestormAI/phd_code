#include "mexHelper.hpp"
#include "Trajectory.hpp"
#include <map>


class circular_constraint
{
public:
    std::pair<Trajectory,Trajectory> trajectories;
    double s;
    
    Point  centre;
    double radius;
    
    circular_constraint( ) {}
    circular_constraint( const Trajectory t1, 
                         const Trajectory t2, 
                         double s_i )
    {
        
        this->trajectories = std::make_pair( t1, t2 );
        this->s = s_i;
        this->calc_radius( );
        this->calc_centre( );
    }
    
    void calc_radius( )
    {
        
        Point dxy[2];
        
        Point dxy1 = trajectories.first.front( ) - trajectories.first.back( );
        
        dxy[0] = trajectories.first.front( ) - trajectories.first.back( );
        dxy[1] = trajectories.second.front( ) - trajectories.second.back( );
        
        
        double top = this->s*(dxy[1].getX( )*dxy[0].getY( ) - dxy[0].getX( )*dxy[1].getY( ));
        double btm = (pow(dxy[0].getY( ),2) - pow(this->s,2)*pow(dxy[1].getY( ),2));
        
        this->radius = fabs(top/btm);
        
//         dxy1.print2D( );
//         ijh::cout << "***********************************************\n";
//         ijh::cout << "dx1: " << dxy[0].getX( ) <<", dx2: " << dxy[1].getX( ) << "\n";
//         ijh::cout << "dy1: " << dxy[0].getY( ) <<", dy2: " << dxy[1].getY( ) << "\n";
//         ijh::cout << "TOP: " << top << "\n";
//         ijh::cout << "BTM: " << btm << "\n";
//         ijh::cout << "Radius: " << this->radius << " (s_i = " << this->s << ")" << std::endl;
//         ijh::mex_cout( );
        
    }
    
    void calc_centre( )
    {
        
        Point dxy[2];
        dxy[0] = trajectories.first.front( ) - trajectories.first.back( );
        dxy[1] = trajectories.second.front( ) - trajectories.second.back( );
        
        double centrex = 
                (dxy[0].getX( )*dxy[0].getY( ) - pow(this->s,2)*dxy[1].getX( )*dxy[1].getY( )) / 
                (pow(dxy[0].getY( ),2) - pow(this->s,2)*pow(dxy[1].getY( ),2));
        
        this->centre = Point( centrex, 0 );
    }
    
    static void constraints2dbl( std::vector<circular_constraint> con, double *dbl )
    {
        int row_id;
        int num_rows = con.size( );
        
        std::vector<circular_constraint>::iterator c;
        
        for( c = con.begin( ); c != con.end( ); c++ )
        {
            
            row_id = abs(distance(con.begin( ), c));
            
            dbl[row_id+0*num_rows] = c->centre.getX( );
            dbl[row_id+1*num_rows] = c->centre.getY( );
            dbl[row_id+2*num_rows] = c->radius;
        }
    }
    
    friend std::ostream& operator<<( std::ostream &out,
                                     const circular_constraint &c )
    {
        out << "(" << c.centre.getX( ) << ", " << c.centre.getY( ) << ") - " << c.radius << std::endl;
        return out;
    }
    
};

void group_trajectories( std::vector<Trajectory> &traj, 
                         std::vector<double> &id, 
                         std::map<int,std::vector<Trajectory> > &grouped)
{
    
    for( uint i=0; i < traj.size( ); i++ )
    {
        grouped[id.at(i)-1].push_back( traj.at(i) );
    }
}

void find_ratios_of_long_components( 
        std::map<int,std::vector<Trajectory> > &grouped,
        std::map<int,double> &ratios,
        std::map<int,std::vector<Trajectory> > &group_representatives)
{
    
    std::map<int,std::vector<Trajectory> >::iterator it;
    for( it = grouped.begin( ); it != grouped.end( ); it++ )
    {
               
//         ijh::cout << "Group " << std::distance(grouped.begin( ),it) << " size: " << it->second.size( ) << "." << std::endl;
        if( it->second.size( ) > 2 ) {
            // Get the two longest trajectories
           std::vector<Trajectory> longest(2);
           Trajectory::longest_pair( it->second, longest );
            
            // now have the ids of the two biggest trajectories, need to
            // get the speed ratio between them
            double speeds[2];
            speeds[0] = longest.at(0).mean_speed( );
            speeds[1] = longest.at(1).mean_speed( );
            
            ratios[it->first] = speeds[0] / speeds[1];
            group_representatives[it->first] = longest;
            
        } else if ( it->second.size( ) == 2 ) {
            // find the ratios
            double speeds[2];
            speeds[0] = it->second.at(0).mean_speed( );
            speeds[1] = it->second.at(1).mean_speed( );
                        
            ratios[it->first] = speeds[0] / speeds[1];
            group_representatives[it->first] = it->second;
        } else { // ignore those that are too short
            ijh::cout << "Group " << std::distance(grouped.begin( ),it) << " too small." << std::endl;
        }
        ijh::mex_cout( );
    }
    
}

/**
 * Using p3, (4) and (5) and the constant-speed length ratios,
 * generate the circular constraints.
 *
 * Returns a vector of constraint structs.
 */
std::vector<circular_constraint> generate_circular_constraints( 
        std::map<int,double> &ratios, 
        std::map<int,std::vector<Trajectory> > &groups )
{
    std::vector<circular_constraint> constraints;
    std::vector<int>::iterator k;
    circular_constraint c;
    
    std::vector<int> keys = ijh::map_keys( groups );
    
    for( k = keys.begin( ); k != keys.end( ); k++ )
    {
        c = circular_constraint( groups[*k].front( ),
                                 groups[*k].back( ),
                                 ratios[*k]
        );
        constraints.push_back(c);
    }
    
    return constraints;
}

/**
 * Generate Type B trajectory groups as per section 4 of Bose paper, then 
 * produce Affine Matrix for metric rectification
 *
 * Inputs:
 *  traj    Set of all valid trajectory segments
 *  ids     Ids from original trajectories (pre-split)
 *
 * Outputs:
 *  - The affine transformation matrix
 *  - A cell array containing all trajectories arranged by their ids
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{

   
    std::vector<Trajectory> traj;
    std::vector<double> ids;
    std::map<int,std::vector<Trajectory> > grouped;
    std::map<int,std::vector<Trajectory> > group_representatives;
    std::map<int, double> group_ratios; //s_i in section 4.1
    std::vector<circular_constraint> constraints;
    
    ijh::check_io chk;
    
    // Check inputs
    chk = ijh::check_io( 2, 2, 0, 2 );
    chk.check(nrhs,nlhs);
    
    
    // Load data from mxArrays
    Trajectory::loadAll( prhs[0], &traj);
    
    ijh::cout << "Loaded " << traj.size( ) << " trajectories." << std::endl;
    
    ijh::mxArray2vector( prhs[1], ids );
    
    // Arrange into sorted vector of trajectories based on id
    group_trajectories( traj, ids, grouped );
    
    find_ratios_of_long_components( grouped, group_ratios, group_representatives );
    
    constraints = generate_circular_constraints( group_ratios, grouped );
    
    plhs[0] = mxCreateDoubleMatrix(constraints.size( ),3,mxREAL);
    double *dbl_0 = mxGetPr(plhs[0]);
    circular_constraint::constraints2dbl( constraints, dbl_0 );
}