#include <math.h>
#include <numeric>
#include "Plane.hpp"
#include "Trajectory.hpp"
#include "functions.hpp"
#include "Matrix.hpp"
#include <algorithm>

#ifndef PI
#define PI 3.1415926535897932384626433832795028841971693993751058209749
#endif

class SimTrajectory: public Trajectory
{
public:
    std::vector<double> speeds;
    std::vector<double> directions;
    int startFrame;
    int endFrame;
    std::vector<float> currentDrn;
    
    bool started;
    bool finished;
    
    SimTrajectory( );
    SimTrajectory( double* spd, double *drn , const mwSize *num_frames); 
    void double2vec( double *in, const int length, std::vector<double> *out );
    
    void addFrame( std::vector<Plane> *planes, int curFrame );
    
    void print3D( );
    
    void start( int frameNo, std::vector<Plane> *planes );
    void finish( int frameNo );
    
    bool isStarted( );
    bool isFinished( );
    
    Point changePlane( std::vector<Plane> *planes, Point *endPos, Point *newPos, int curFrame );
    Matrix drn2mat( int frameNo, Plane *plane );
    
    void newStartingPoint( std::vector<Plane> *planes );
private:
    bool reversal;
};