#ifndef _IJH_PLANE_
#define _IJH_PLANE_ 1

#include <math.h>
#include <vector>
#include <iterator>
#include <limits>
#include <sstream>
#include "Point.hpp"
#include "mex.h"
#include "matrix.h"
#include "functions.hpp"
#include "Line.cpp"

#ifndef PI
#define PI 3.1415926535897932384626433832795028841971693993751058209749
#endif


class Plane
{
public:
    std::vector<Point> boundaries;
    Point minboundaries;
    Point maxboundaries;
    std::vector<float> n;
    float d;
    int id;
    Plane( ) {}
    Plane( double *boundDbl, const mwSize *boundaryDims, double *paramsDbl, int id = -1);
    
    Matrix getDrn( bool switcharoo = false );
    
    void boundariesFromDouble( double *boundaries , const mwSize *dims );

    void minmaxBounds( );
    
    void print( );
    
    bool checkBounds( Point p, bool notZ=false, bool debug=false);
    
    void intersect( Plane &b, double (&n)[3] );
    
    static Plane* findPlane( std::vector<Plane> *planes, Point pos, bool debug=false );
    static std::vector<Point> intersection( Plane *oldPlane, Plane *newPlane );
    static void anglesFromN( std::vector<float> n, float *theta, float *psi);
};
#endif