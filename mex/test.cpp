#include "mexHelper.hpp"
#include "Trajectory.hpp"
#include <map>

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{

   
    std::vector<Trajectory> traj;
    std::vector<Trajectory> longest(2);
    ijh::check_io chk;
    
    // Check inputs
    chk = ijh::check_io( 1, 1, 0, 1 );
    chk.check(nrhs,nlhs);
    
    
    Trajectory::loadAll( prhs[0], &traj);
    
    /*std::vector<Trajectory>::iterator it;
    for(it = traj.begin( ); it != traj.end( ); it++ )
        ijh::cout << *it << "\n\n";
    ijh::mex_cout( );
    ijh::cout << "Loaded Trajectories" << std::endl;
    ijh::mex_cout( );
    Trajectory::longest_pair( traj, longest );
    ijh::cout << "Got pair" << std::endl;
    
    plhs[0] = mxCreateCellMatrix(longest.size( ),1);
    Trajectory::outputAll( &longest, plhs[0] );
    ijh::cout << "Output" << std::endl;
    ijh::mex_cout( );*/
    
//     double mn = traj.at(0).mean_speed( );
//     
//     ijh::cout << mn << std::endl;
//     ijh::mex_cout( );
//     
//     plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
//     double *ptr = mxGetPr( plhs[0] );
//     ptr[0] = mn;
    
    
    Trajectory t = traj.at(0);
    std::vector<double> p = t.to1D( );
    
    
	ijh::printVector( p );
    ijh::mex_cout( );
    
    plhs[0] = mxCreateDoubleMatrix(p.size( ),1,mxREAL);
    ijh::vector2mxArray( p, plhs[0] );
    
    
}