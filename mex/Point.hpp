#ifndef _IJH_POINT
#define _IJH_POINT 1

#include <math.h>
#include "camcal_pets/cameraModel.h"
#include "camcal_pets/xmlUtil.h"
#include "mex.h"
#include "matrix.h"
#include "Matrix.hpp"
#include "mexHelper.hpp"
#include <sstream>
#include <iomanip>
#include <vector> 
#include <iterator>
#include <iostream>

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
       
       void print2D( ) const;
       std::string toStr2D( ) const;
       
       void print3D( ) const;
       std::string toStr3D( ) const;
       
       double dist2D( const Point pt ) const;
       
       void calibTsai( Etiseo::CameraModel *cam );
       
       Point move( Matrix *drn, float spd );
       
       friend bool operator== (Point &p1, Point &p2);
       friend bool operator!= (Point &p1, Point &p2);

       friend Point operator+ (const Point &p1, const Point &p2);
       friend Point operator- (const Point &p1, const Point &p2);
       
       Point cross( Point p );
       
       bool isNull( );
       
       Matrix toMatrix( );
       
       static Point fromString( std::string str );
};
#endif
