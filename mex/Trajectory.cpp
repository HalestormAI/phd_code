#include "Trajectory.hpp"

Trajectory::Trajectory( ) {
    this->is2D = false;
    this->is3D = false;
}

Trajectory::Trajectory( double *traj, const mwSize *dims ) {
    this->is2D = false;
    this->is3D = false;
    if( dims[0] == 2 )
        this->fromDouble( traj, dims );
    else
        this->fromDouble3D( traj, dims );
}

void Trajectory::fromDouble( double* traj, const mwSize *dims ) {

    double x,y;
    for(int col=0;col < dims[1]; col++) {
        x = traj[0+col*dims[0]];
        y = traj[1+col*dims[0]];
        points.push_back( Point( x, y ) );
    }
    this->is2D = true;
}

void Trajectory::fromDouble3D( double* traj, const mwSize *dims ) {

    float x,y,z;
    for(int col=0;col < dims[1]; col++) {
        x = traj[0+col*dims[0]];
        y = traj[1+col*dims[0]];
        z = traj[2+col*dims[0]];
        points.push_back( Point( x, y, z ) );
    }
    this->is3D = true;
}

void Trajectory::toDouble2D( double *traj ) const
{
    for( int col=0; col<this->points.size( ); col++ ) {
        traj[0+col*2] = this->points.at(col).getX();
        traj[1+col*2] = this->points.at(col).getY();
    }
}

void Trajectory::toDouble3D( double *traj ) const
{
    for( int col=0; col<this->points.size( ); col++ ) {
        traj[0+col*3] = this->points.at(col).getX();
        traj[1+col*3] = this->points.at(col).getY();
        traj[2+col*3] = this->points.at(col).getZ();
    }
}

void Trajectory::print2D( ) const
{
    std::vector<Point>::const_iterator i;
    for( i = this->points.begin( ); i != this->points.end( ); i++ )
    {
        i->print2D( );
    }
}

void Trajectory::print3D( ) const
{
    std::vector<Point>::const_iterator i;
    for( i = this->points.begin( ); i != this->points.end( ); i++ ){
        i->print3D( );
    }
}

Point Trajectory::at( int idx ) const
{
    return this->points.at( idx );
}

Point Trajectory::front( ) const 
{
    return this->points.front( );
}

Point Trajectory::back( ) const
{
    return this->points.back( );
}

uint Trajectory::length( ) const
{
    return this->points.size( );
}

/**
 * Get the vector of speeds for each pair of points along the trajectory
 */
std::vector<double> Trajectory::frame_speeds( ) const
{
    
    std::vector<double> speeds;
    for( uint i=1; i < this->length( ); i++ )
    {
        speeds.push_back(this->points.at(i).dist2D( this->points.at(i-1)));
    }
    
    return speeds;
}

/**
 * Get the mean speed of the trajectory
 */
double Trajectory::mean_speed( ) const 
{
    
    std::vector<double> speeds = this->frame_speeds( );
    double distance_sum = std::accumulate(speeds.begin(), speeds.end(), 0);
    
    return distance_sum / (this->length( )-1);
}

std::vector<double> Trajectory::to1D( ) const
{
    std::vector<double> pos = this->frame_speeds( );
    std::vector<double> pos1d(pos.size( ));
    
    // Cumulative sum
    std::partial_sum(pos.begin(), pos.end(), pos1d.begin(), std::plus<double>());
    
    std::transform( 
            pos1d.begin(), 
            pos1d.end(), 
            pos1d.begin(), 
            std::bind2nd( std::minus<double>(), pos1d.front( ) )
    ); // Subtract pos1d[0] from pos1d[0...n]
    
    return pos1d;
}

void Trajectory::addPoint3D(float x, float y,float z)
{
    if( this->is2D ) {
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidDim",
                "This is a 2D trajectory - cannot add a 3D point.");
    }
    this->points.push_back( Point( x,y,z ) );
    this->is3D = true;
}

void Trajectory::addPoint(Point p) {
    if( p.is3D && this->is2D ) {
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidDim",
                "This is a 2D trajectory - cannot add a 3D point.");
    } else if( p.is2D && this->is3D ) {
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidDim",
                "This is a 3D trajectory - cannot add a 2D point.");
    }
    this->points.push_back( p );
    
    if( p.is2D )
        this->is2D = true;
    else
        this->is3D = true;
}

float Trajectory::angleDiff( int aIdx, const Trajectory &t, int bIdx ) const {

//         mexPrintf("%d %d %d (%d)\n%d %d %d (%d)\n\n", aIdx-1, aIdx, aIdx+1, this->points.size( ), bIdx-1, bIdx, bIdx+1, t->points.size( ));

    Point p1a = this->at(aIdx-1);
    Point p2a = this->at( aIdx );
    Point p3a = this->at(aIdx+1);

    Point p1b = t.at(bIdx-1);
    Point p2b = t.at( bIdx );
    Point p3b = t.at(bIdx+1);

    Line l1a = Line( p1a, p2a );
    Line l2a = Line( p2a, p3a );
    Line l1b = Line( p1b, p2b );
    Line l2b = Line( p2b, p3b );

    float ang1 = l1a.ang( l2a );
    float ang2 = l1b.ang( l2b );

    return abs( ang1/PI - ang2/PI );
}

#ifdef USE_ETSIO
void Trajectory::calibTsai( Etiseo::CameraModel *cam ) {
    std::vector<Point>::iterator i;
    for( i = this->points.begin( ); i != this->points.end( ); i++ ){
        i->calibTsai( cam );
    }
    this->is3D = true;
}
#endif

Trajectory Trajectory::subtrajectory( std::vector<int> ids )
{
    
    Trajectory sub;
    
    std::vector<int>::iterator i;
    
    for( i = ids.begin( ); i != ids.end( ); i++ ) {
        sub.addPoint( this->at( *i ) );
    }
    
    return sub;
}

std::string Trajectory::toStr( ) const {
    std::stringstream s;
    
    std::vector<Point>::const_iterator i;
    for( i = this->points.begin( ); i != this->points.end( ); i++ ){
        
        if( this->is3D )
            s << i->toStr3D( );
        else
            s << i->toStr2D( );
    }    
    
    return s.str( );
}

void Trajectory::toFile( std::string filename )
{
    std::string str = this->toStr( );
    std::ofstream output;
    output.open( filename.c_str( ) );
    output << this->toStr( );
    output.close( );
}

void Trajectory::fromFile( std::string filename )
{
    // Load in all lines into vector
    std::ifstream input;
    input.open(filename.c_str( ));
    std::string lineTmp;
    while(std::getline( input, lineTmp)) 
    {
        this->addPoint( Point::fromString( lineTmp ) );
    }
    
}



std::ostream& operator<<( std::ostream &out, const Trajectory &t ) {
    out << t.toStr( );
    return out;
}

// STATIC METHODS

/**
 * Helper for transform in Trajectory::lengths
 */
int _trajectory_length( Trajectory &t) { return t.length( ); }

/**
 * Get vector of lengths of all trajectories in a vector
 */
std::vector<int> Trajectory::lengths( std::vector<Trajectory> &traj )
{
    
    std::vector<int> l(traj.size( ));
    
    std::transform(traj.begin( ), traj.end( ), l.begin( ), _trajectory_length );
    
    return l;
}

/**
 * Finds longest pair of trajectories from a vector
 */
void Trajectory::longest_pair( std::vector<Trajectory> &trajs, std::vector<Trajectory> &longest )
{
    std::vector<int> lengths = Trajectory::lengths( trajs );
    std::vector<int>::iterator l_it;

    int max_val[2] = {-1,-1}; // [0] is largest, [1] is 2nd largest
    int max_ids[2] = {-1,-1};

    for( l_it = lengths.begin( ); l_it != lengths.end( ); l_it++ )
    {
        // if it's maxer than the maxest
        if( (*l_it) > max_val[0] ) { 
            // bump current top-spot to 2nd
            max_ids[1] = max_ids[0];
            max_val[1] = max_val[0];
            // Get current id
            max_ids[0] = std::distance(lengths.begin( ),l_it);;
            max_val[0] = *l_it;
        } else if( (*l_it) > max_val[1] ) {
            // Just replace 2nd place
            max_ids[1] = std::distance(lengths.begin( ), l_it);
            max_val[1] = *l_it;
        }
    }
    
    longest[0] = trajs.at(max_ids[0]);
    longest[1] = trajs.at(max_ids[1]);
} 

/**
 * Load all trajectories from mex Cell Array
 */
void Trajectory::loadAll( const mxArray *prhs, std::vector<Trajectory> *alltraj ) {
    const mwSize *tDims = mxGetDimensions( prhs );
    const mwSize *trajDims;
    
    // Account for row and column cell arrays
    int idx0 = 0,
        idx1 = 1;
    
    if( tDims[0] == 1 && tDims[1] > 1 ) {
        idx0 = 1;
        idx1 = 0;
    }
    
    mxArray *mx_traj;
    for( int t=0; t<tDims[idx0]; t++ ) {
        mx_traj = (mxArray*)mxGetCell(prhs,t);
        trajDims = mxGetDimensions( mx_traj );
        
        Trajectory t1 = Trajectory( );
        if( trajDims[0] == 2 ) {
            t1.fromDouble( mxGetPr( mx_traj), trajDims  );
        } else if( trajDims[0] == 3 ) {
            t1.fromDouble3D( mxGetPr( mx_traj), trajDims  );
        } else {
            mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidsize",
                    "Trajectory should be 3xn." );
        }
        
        alltraj->push_back( t1 );
    }
}

void Trajectory::outputAll( std::vector<Trajectory> *traj, mxArray *out ) 
{
    std::vector<Trajectory>::iterator j;
    int cellCount = 0;
    
    for( j=traj->begin( ); j != traj->end( ); j++ ) {
        mxArray *mx_traj = mxCreateDoubleMatrix(2,j->length( ),mxREAL);
        double *mxd_traj = mxGetPr(mx_traj);
        j->toDouble2D( mxd_traj );
        mxSetCell( out, cellCount++, mx_traj );
    }
}

/** TODO
double errorfunc( double theta, 
                  double psi, 
                  double d, 
                  double foc, 
                  std::vector<Trajectory> trajectories )
{
    
    vector<int> trajectoryLengths
    
}*/