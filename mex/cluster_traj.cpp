#include "mex.h"
#include "matrix.h"
#include <vector>
#include <map>
#include <iterator>
#include <math.h>
#include <iostream>

#define PI 3.14159265358979323846
#define DEG2RAD(DEG) ((DEG)*((PI)/(180.0)))

using namespace std;

class Point
{
public:
       float x, y;
       float X,Y,Z;
       
       Point( float ix, float iy ) {
           this->x = ix;
           this->y = iy;
       }
       
       void print2D( ) {
            cout << this->x << "\t" << this->y << endl;
       }
       
       void print3D( ) {
            cout << this->X << "\t" << this->Y << "\t" << this->Z << endl;
       }
       
       float dist2D( Point pt ) {
            float dx = (this->x - pt.x);
            float dy = (this->y - pt.y);

            float dist = sqrt(pow(dx,2) + pow(dy,2));
            return dist;
       }
};

class Trajectory
{
public:
    vector<Point> points;
    
    Trajectory( double *traj, const mwSize *dims ) {
        this->fromDouble( traj, dims );
    }
    
    void fromDouble( double* traj, const mwSize *dims ) {
    
        float x,y;
        for(int col=0;col < dims[1]; col++) {
            x = traj[0+col*dims[0]];
            y = traj[1+col*dims[0]];
            points.push_back( Point( x, y ) );
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
    
    uint length( ) {
        return this->points.size( );
    }

    Point at( int idx ) {
        return this->points.at(idx);
    }
        
};

class Matrix
{
    public:
        map< int, map<int, float> > elems;
        int rows;
        int cols;

        Matrix( ) {}

        Matrix( int numRows, int numCols ) {
            this->rows = numRows;
            this->cols = numCols;
            for( int i=0; i<numRows; i++ ) {
                map<int, float> row;
                this->elems[i] = row;
            }
        }

        float set( int i, int j, float val ) {
            this->elems[i][j] = val;
        }

        float at( int i, int j ) {
            return this->elems[i][j];
        }

        void toDouble( double *dbl ) {
            for( int i=0; i < this->rows; i++ ) {
                for( int j=0; j < this->cols; j++ ) {
                    dbl[i+j*this->rows] = this->at(i,j);
                }
            }
        }

        void print( ) {
            for( int i=0; i < this->rows; i++ ) {
                printf( "[ " );
                for( int j=0; j < this->cols; j++ ) {
                    printf( "%g ", this->at(i,j) );
                }
                printf( " ]\n" );
            }
        }

};

void vec2double( double *dbl, vector<pair<int,int> > *vec ) {
    int counter = 0;
    int numRows = vec->size( );

    for( int i=1; i < vec->size( ); i++ ) {
        dbl[i + 0*numRows] = vec->at(i).first;
        dbl[i + 1*numRows] = vec->at(i).second;
    }
}

void matching_cost( Matrix *Q, Trajectory *A, Trajectory *B ) {

    int M = A->length( );
    int N = B->length( );

    (*Q) = Matrix( M, N );

    for( int m=0; m < M; m++ ) {
        for( int n=0; n < N; n++ ) {
            float dist = A->at(m).dist2D( B->at(n) );
            Q->set(m,n,dist);
        }
    }

}

    
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    const mwSize *dims1, *dims2;
    double *trajData1, *trajData2, *lss_output, *Q_output;
    Matrix Q;

    int tol_e, tol_d;
    
    /* check proper input and output */
    if(nrhs!=2)
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidNumInputs",
                "5 inputs required.");
    else if(nlhs > 2)
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:maxlhs",
                "Too many output arguments.");
    else if(!mxIsDouble(prhs[0]))
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:inputNotStruct",
                "Input must be a cell.");
   
    // Get normal from theta and psi
    trajData1 = (double*)mxGetPr( prhs[0] );
    dims1 = mxGetDimensions( prhs[0] );

    trajData2 = (double*)mxGetPr( prhs[1] );
    dims2 = mxGetDimensions( prhs[1] );

    Trajectory traj1 = Trajectory( trajData1, dims1 );
    Trajectory traj2 = Trajectory( trajData2, dims2 );

    matching_cost( &Q, &traj1, &traj2 );
    

    plhs[0] = mxCreateDoubleMatrix( Q.rows, Q.cols, mxREAL );

    Q_output = mxGetPr( plhs[0] );

    Q.toDouble( Q_output );
    
}
