#ifndef _IJH_POINT
#define _IJH_POINT 1

#include <math.h>
#include "camcal_pets/cameraModel.h"
#include "camcal_pets/xmlUtil.h"
#include "mex.h"
#include "matrix.h"
#include "Matrix.hpp"
#include <sstream>
#include <iomanip>
#include <vector> 
class Point
{
    public:
       double x, y;
       double X,Y,Z;
       
       bool is2D;
       bool is3D;
       
       bool onPlane;
       
       bool isN;
       
       Point( );
       Point( double ix, double iy );
       Point( Matrix m );
       
       Point( double wx, double wy, double wz );
       
       void print2D( );
       
       void print3D( );
       std::string toStr3D( );
       
       double dist2D( Point pt );
       
       void calibTsai( Etiseo::CameraModel *cam );
       
       Point move( Matrix *drn, float spd );
       
       friend bool operator== (Point &p1, Point &p2);
       friend bool operator!= (Point &p1, Point &p2);

       friend Point operator+ (const Point &p1, const Point &p2);
       friend Point operator- (const Point &p1, const Point &p2);
       
       Point cross( Point p );
       
       bool isNull( );
       
       Matrix toMatrix( );
};
#endif