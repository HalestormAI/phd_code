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
    private:
       double x, y;
       double X,Y,Z;
    public:
        
       double getX( ) const { return (is2D ? x : X); }
       double getY( ) const { return (is2D ? y : Y); }
       double getZ( ) const { if(is2D) mexErrMsgTxt("Tried to get 3D point from 2D Point"); return Z; }
       
       void setX( double x1 ) {
           if(is2D)
               x = x1;
           else
               X = x1;
       }
       void setY( double x1 ) {
           if(is2D)
               y = x1;
           else
               Y = x1;
       }
       void setZ( double x1 ) {
           if(is2D)
               mexErrMsgTxt("Tried to set Z on 2D Point");
           else
               Z = x1;
       }
       
       bool is2D;
       bool is3D;
       
       bool onPlane;
       
       bool isN;
       
       Point( );
       Point( double ix, double iy );
       Point( Matrix m );
       
       Point( double wx, double wy, double wz );
       
       void print( ) const;
       std::string toStr( ) const;
       
       void print2D( ) const;
       std::string toStr2D( ) const;
       
       void print3D( ) const;
       std::string toStr3D( ) const;
       
       double dist2D( const Point pt ) const;
       double dist( const Point pt ) const;
       
       void calibTsai( Etiseo::CameraModel *cam );
       
       Point move( Matrix *drn, float spd ) const;
       
       friend bool operator== (Point &p1, Point &p2);
       friend bool operator!= (Point &p1, Point &p2);

       friend Point operator+ (const Point &p1, const Point &p2);
       friend Point operator- (const Point &p1, const Point &p2);
       friend Point operator/ (const Point &p1, const double val);
       friend Point operator* (const double val, const Point &p1);
       
       Point cross( Point p );
       
       bool isNull( );
       
       Matrix toMatrix( ) const;
       
       void toDouble( double *out );
       
       static Point fromString( std::string str );
};
#endif
