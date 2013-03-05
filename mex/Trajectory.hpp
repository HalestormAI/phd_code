#include <math.h>
#include <vector>
#include <fstream>
#include "camcal_pets/cameraModel.h"
#include "camcal_pets/xmlUtil.h"
#include "mex.h"
#include "matrix.h"
#include "Point.hpp"
#include "Line.cpp"

#ifndef PI
#define PI 3.1415926535897932384626433832795028841971693993751058209749
#endif

class Trajectory
{
public:
    std::vector<Point> points;
    
    bool is3D;
    bool is2D;
    
    Trajectory( );
    Trajectory( double *traj, const mwSize *dims );
    
    void fromDouble( double* traj, const mwSize *dims );    
    void fromDouble3D( double* traj, const mwSize *dims );
    
    void toDouble2D( double *traj );    
    void toDouble3D( double *traj );
    
    void print2D( );    
    void print3D( );
    
    uint length( ) const;

    Point at( int idx ) const;
    
    void addPoint3D(float x, float y,float z);    
    void addPoint(Point p);
       
    float angleDiff( int aIdx, const Trajectory &t, int bIdx ) const;    
    void calibTsai( Etiseo::CameraModel *cam );
    
    Trajectory subtrajectory( std::vector<int> ids );
    std::string toStr( );
    void toFile( std::string filename );
    void fromFile( std::string filename );

    
    static void loadAll( const mxArray *prhs, std::vector<Trajectory> *alltraj );
    static void outputAll( std::vector<Trajectory> *traj, mxArray *out );
};