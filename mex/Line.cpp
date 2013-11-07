#ifndef _IJH_LINE_
#define _IJH_LINE_ 1

#include <math.h>
#include "Point.hpp"

class Line
{
public:
    Point start;
    Point end;
    float m,c;
    Line ( ) {}
    Line( Point p1, Point p2 ) {
        this->start = p1;
        this->end = p2;
        
        float dx = p1.getX( ) - p2.getX( );
        float dy = p1.getY( ) - p2.getY( );
        
        this->m = dy/dx;
        
        this->c = p1.getY( ) - this->m*p1.getX( );
    }
    
    void getDrn( double (&drn)[3] ) {
        Matrix drnMat = this->start.cross(this->end).toMatrix( );
        drnMat /= drnMat.mag( );
        drnMat.toDouble( drn );
    }
    
    float ang( Line l ) {
        return atan( abs( (this->m - l.m) / (1+this->m*l.m) ) );
    }
    
     Point centroid( )
     {
         return (start+end)/2;
     }
     
     static bool checkPointOnLine( Point p1, double drn[3], Point check ) {
        double lambda;
        bool checkVal;
        
        mexPrintf("Line.cpp(45): \n");
        p1.print( );
        check.print( );
        mexPrintf("Drn: %g\t%g\t%g\n", drn[0],drn[1],drn[2]);
        
        if(!p1.is3D || !check.is3D)
            mexErrMsgTxt("P1 and check must be 3d...");
        
        if( drn[0] == 0 ) {
            lambda = (p1.getY( ) - check.getY( )) / drn[1];
            checkVal = p1.getZ( ) == (lambda*drn[2] + check.getZ( ));
        } else {
            lambda = (p1.getX( ) - check.getX( )) / drn[0];
            if(  drn[3] == 0 ) {
                checkVal = (p1.getY( ) == lambda*drn[1] + check.getY( ));
                if(!checkVal) {
                     mexPrintf("**P1y: %g, Check: %g\n\n", p1.getY( ), lambda*drn[1] + check.getY( ));
                }
            } else {
                checkVal = (p1.getZ( ) == lambda*drn[2] + check.getZ( ));
                if(!checkVal) {
                     mexPrintf("**P1z: %g, Check: %g\n\n", p1.getZ( ), lambda*drn[2] + check.getZ( ));
                }
            }
        }
        return checkVal;
    }
     
     double point_distance( Point x0p )
     {
         double d;
         
         Matrix x1 = this->start.toMatrix( );
         Matrix x2 = this->end.toMatrix( );
         Matrix x0 = x0p.toMatrix( );
         
         Matrix x2x1diff = (x2-x1);
         Matrix x1x0diff = x1-x0;
         
         d = Matrix::cross(x2x1diff,x1x0diff).mag( ) / x2x1diff.mag( );
         
         return d;         
     }
     
     void print( )
     {
         this->start.print( );
         this->end.print( );
     }
};

#endif