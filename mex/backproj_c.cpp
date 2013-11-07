#include "mex.h"
#include "matrix.h"
#include <vector>
#include <iterator>
#include <math.h>
#include <iostream>

#define PI 3.14159265358979323846
#define DEG2RAD(DEG) ((DEG)*((PI)/(180.0)))
#define RAD2DEG(RAD) ((RAD)*((180.0)/(PI)))

using namespace std;

class Params
{
public:  
    float nx,ny,nz,theta,psi,d,foc;
    
    Params( float t, float p, float d, float f ) {
        this->theta = t;
        this->psi   = p;
        this->d     = d;
        this->foc   = f;
        
        this->normalFromAngles( );
    }
    
    Params( double n[], float d, float f )
    {
        this->theta = RAD2DEG( acos(n[2]) );
        if( this->theta == 0 )
            this->psi = RAD2DEG( asin(-n[0]) );
        else
            this->psi = RAD2DEG( asin(-n[0]) / sin(DEG2RAD(this->theta)) );
        
        this->nx = n[0];
        this->ny = n[1];
        this->nz = n[2];
        
        this->d = d;
        this->foc = f;
    }
    
    void normalFromAngles( ) {
        this->nx = -sin(-DEG2RAD(this->psi))*sin(-DEG2RAD(this->theta));
        this->ny = -cos(-DEG2RAD(this->psi))*sin(-DEG2RAD(this->theta));
        this->nz = -cos(-DEG2RAD(this->theta));
    }
};

class Point
{
public:
       float x, y;
       float X,Y,Z;
       Params *params;
       
       Point( float ix, float iy, Params *p ) {
           this->x = ix;
           this->y = iy;
           this->params = p;
       }
       
       void print2D( ) {
            cout << this->x << "\t" << this->y << endl;
       }
       
       void print3D( ) {
            cout << this->X << "\t" << this->Y << "\t" << this->Z << endl;
       }
       
       void rectify( ) {
           Params *p = this->params;
           this->Z = p->d / (p->foc*this->x*p->nx + p->foc*this->y*p->ny + p->nz);
           this->X = p->foc*this->x*this->Z;
           this->Y = p->foc*this->y*this->Z;
       }
};

class Trajectory
{
public:
    vector<Point> points;
    Params *params;
    
    Trajectory( double *traj, const mwSize *dims, Params *p ) {
        this->params = p;
        this->from_double( traj, dims );
    }
    
    void from_double( double* traj, const mwSize *dims ) {
    
        float x,y;
        for(int col=0;col < dims[1]; col++) {
            x = traj[0+col*dims[0]];
            y = traj[1+col*dims[0]];
            points.push_back( Point( x, y, this->params) );
        }
    }
    
    void toDouble( double *traj ) {
        for( int col=0; col<this->points.size( ); col++ ) {
            traj[0+col*3] = this->points.at(col).X;
            traj[1+col*3] = this->points.at(col).Y;
            traj[2+col*3] = this->points.at(col).Z;
        }
    }
    
    void print2D( ) {
        vector<Point>::iterator i;
        for( i = this->points.begin( ); i != this->points.end( ); i++ ){
            i->print2D( );
        }
    }
    
    void print3D( ) {
        vector<Point>::iterator i;
        for( i = this->points.begin( ); i != this->points.end( ); i++ ){
            i->print3D( );
        }
    }
    
    void rectify( ) {
        vector<Point>::iterator i;
        for( i = this->points.begin( ); i != this->points.end( ); i++ ){
            i->rectify( );
        }
    }
    
    uint length( ) {
        return this->points.size( );
    }
        
};
    
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    const mwSize *dims;
    double *trajData, *output;
    
    /* check proper input and output */
    if(nrhs < 4 || nrhs > 5 )
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidNumInputs",
                "4/5 inputs required.");
    else if(nlhs > 5)
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:maxlhs",
                "Too many output arguments.");
    else if(!mxIsDouble(prhs[0]))
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:inputNotStruct",
                "Input must be a cell.");
   
    // Get normal from theta and psi
    Params *params;
    int trajPos = 3;
    if( nrhs == 4 ) {
        // need to get 3x1 double for n
        // then scalars for d and f.
        
        double* n_dbl = (double*)mxGetPr( prhs[0] );
        
        params = new Params( n_dbl, 
                             mxGetScalar(prhs[1]),
                             mxGetScalar(prhs[2]) );
        trajPos = 3;
    } else if( nrhs == 5 ) {
    
        params = new Params( mxGetScalar(prhs[0]),
                             mxGetScalar(prhs[1]),
                             mxGetScalar(prhs[2]),
                             mxGetScalar(prhs[3]) );
        trajPos = 4;
    }
    
    trajData = (double*)mxGetPr( prhs[trajPos] );
    dims = mxGetDimensions( prhs[trajPos] );
    
    Trajectory traj = Trajectory( trajData, dims, params );
    traj.rectify( );
    
    plhs[0] = mxCreateDoubleMatrix(3,traj.length( ),mxREAL);
    output = mxGetPr( plhs[0] );
    traj.toDouble( output );
}