#include <math.h>
#include <vector>
#include <fstream>
#include <algorithm>
#include <numeric>
#include "mexHelper.hpp"
#ifdef USE_ETSIO
#include "camcal_pets/cameraModel.h"
#include "camcal_pets/xmlUtil.h"
#endif

#ifndef uint
#define uint int
#endif

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
    
    void toDouble2D( double *traj ) const;    
    void toDouble3D( double *traj ) const;
    
    void print2D( ) const;    
    void print3D( ) const;
    
    
    uint length( ) const;
    Point front( ) const;
    Point back( ) const;
    Point at( int ) const;
    
    std::vector<double> frame_speeds( ) const;
    double mean_speed( ) const;
    
    std::vector<double> to1D( ) const;
    
    void addPoint3D(float x, float y,float z);    
    void addPoint(Point p);
       
    float angleDiff( int aIdx, const Trajectory &t, int bIdx ) const;    
    #ifdef USE_ETSIO
    void calibTsai( Etiseo::CameraModel *cam );
    #endif
    Trajectory subtrajectory( std::vector<int> ids );
    std::string toStr( ) const;
    void toFile( std::string filename );
    void fromFile( std::string filename );
    
    friend std::ostream& operator<<( std::ostream &out, const Trajectory &t );

    static int length( const Trajectory& );
    static std::vector<int> lengths( std::vector<Trajectory>& );
    static void longest_pair( std::vector<Trajectory> &, std::vector<Trajectory> &);
    static void loadAll( const mxArray *prhs, std::vector<Trajectory> *alltraj );
    static void outputAll( std::vector<Trajectory> *traj, mxArray *out );
};
