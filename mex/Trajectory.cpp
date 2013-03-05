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

void Trajectory::toDouble2D( double *traj ) {
    for( int col=0; col<this->points.size( ); col++ ) {
        traj[0+col*2] = this->points.at(col).x;
        traj[1+col*2] = this->points.at(col).y;
    }
}

void Trajectory::toDouble3D( double *traj ) {
    for( int col=0; col<this->points.size( ); col++ ) {
        traj[0+col*3] = this->points.at(col).X;
        traj[1+col*3] = this->points.at(col).Y;
        traj[2+col*3] = this->points.at(col).Z;
    }
}

void Trajectory::print2D( ) {
    std::vector<Point>::iterator i;
    for( i = this->points.begin( ); i != this->points.end( ); i++ ){
        i->print2D( );
    }
}

void Trajectory::print3D( ) {
    std::vector<Point>::iterator i;
    for( i = this->points.begin( ); i != this->points.end( ); i++ ){
        i->print3D( );
    }
}

uint Trajectory::length( ) const {
    return this->points.size( );
}

Point Trajectory::at( int idx ) const {
    return this->points.at(idx);
}

void Trajectory::addPoint3D(float x, float y,float z) {
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

void Trajectory::calibTsai( Etiseo::CameraModel *cam ) {
    std::vector<Point>::iterator i;
    for( i = this->points.begin( ); i != this->points.end( ); i++ ){
        i->calibTsai( cam );
    }
}

Trajectory Trajectory::subtrajectory( std::vector<int> ids )
{
    
    Trajectory sub;
    
    std::vector<int>::iterator i;
    
    for( i = ids.begin( ); i != ids.end( ); i++ ) {
        sub.addPoint( this->at( *i ) );
    }
    
    return sub;
}

std::string Trajectory::toStr( ) {
    std::stringstream s;
    
    std::vector<Point>::iterator i;
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

// STATIC METHODS

void Trajectory::loadAll( const mxArray *prhs, std::vector<Trajectory> *alltraj ) {
    const mwSize *tDims = mxGetDimensions( prhs );
    const mwSize *trajDims;
    
    mxArray *mx_traj;
    for( int t=0; t<tDims[0]; t++ ) {
        mx_traj = (mxArray*)mxGetCell(prhs,t);
        trajDims = mxGetDimensions( mx_traj );
        
        Trajectory t = Trajectory( );
        if( trajDims[0] == 2 ) {
            t.fromDouble( mxGetPr( mx_traj), trajDims  );
        } else if( trajDims[0] == 3 ) {
            t.fromDouble3D( mxGetPr( mx_traj), trajDims  );
        } else {
            mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidsize",
                    "Trajectory should be 3xn." );
        }
        
        alltraj->push_back( t );
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