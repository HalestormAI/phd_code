#include "mex.h"
#include "matrix.h"
#include <vector>
#include <map>
#include <iterator>
#include <math.h>
#include <iostream>
#include "mexHelper.cpp"
#include "Matrix.cpp"
#include "Trajectory.hpp"

#ifndef PI
#define PI 3.1415926535897932384626433832795028841971693993751058209749
#endif

#define DEG2RAD(DEG) ((DEG)*((PI)/(180.0)))

using namespace std;


void vec2double( double *dbl, vector<pair<int,int> > *vec ) {
    int counter = 0;
    int numRows = vec->size( );

    for( int i=1; i < vec->size( ); i++ ) {
        dbl[i + 0*numRows] = vec->at(i).first;
        dbl[i + 1*numRows] = vec->at(i).second;
    }
}

void matching_cost( Matrix &Q, const Trajectory &A, const Trajectory &B, double *w ) {

    int M = A.length( );
    int N = B.length( );

    Q = Matrix( M, N );

    for( int m=0; m < M; m++ ) {
        for( int n=0; n < N; n++ ) {
            float dist = w[1]*(A.at(m).dist2D( B.at(n) ));
            float drn = 1;
            if( (m > 0) && (m < M-1) && (n > 0) && (n < N-1) )
                drn = w[0]*(A.angleDiff( m, B, n ));
//             if( m==n )
//                 Q->set(m,n,999999);
//             else
                Q.set(m,n,drn+dist);
        }
    }

}




void direction_cost( Matrix &Q, const Trajectory &A, const Trajectory &B) {

    int M = A.length( );
    int N = B.length( );

    Q = Matrix( M, N );

    for( int m=0; m < M; m++ ) {
        for( int n=0; n < N; n++ ) {
            float drn = 1;
            if( (m > 0) && (m < M-1) && (n > 0) && (n < N-1) )
                drn = A.angleDiff( m, B, n );
//             if( m==n )
//                 Q->set(m,n,999999);
//             else
                Q.set(m,n,drn);
        }
    }

}



void distance_cost( Matrix &Q, const Trajectory &A, const Trajectory &B) {

    int M = A.length( );
    int N = B.length( );

    Q = Matrix( M, N );

    for( int m=0; m < M; m++ ) {
        for( int n=0; n < N; n++ ) {
            float dist = A.at(m).dist2D( B.at(n) );
//             if( m==n )
//                 Q->set(m,n,999999);
//             else
                Q.set(m,n,dist);
        }
    }

}


    
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    const mwSize *dims1, *dims2, *weight_dims;
    double *trajData1, 
           *trajData2,
           *weight,
           *lss_output, 
           *Q_output, 
           *A_output, 
           *D_output;
    
    Matrix Q;

    int tol_e, tol_d;
    
    bool need_to_free = false;
    
    /* check proper input and output */
    if(nrhs>3 || nrhs < 2)
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidNumInputs",
                "Usage: [...] = cluster_traj(trajectory_1, trajectory_2[, weight]);\n\n\ttrajectory_1\t2xm double\n\ttrajectory_2\t2xn double\n\tweight\t\t2x1 double (w_shape, w_distance)");
    else if(nlhs > 3)
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:maxlhs",
                "Too many output arguments.");
    else if(!mxIsDouble(prhs[0]))
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:inputNotDouble",
                "Input must be a double.");
    else if(!mxIsDouble(prhs[1]))
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:inputNotDouble",
                "Input must be a double.");
   
    // Get trajectory data
    trajData1 = (double*)mxGetPr( prhs[0] );
    dims1 = mxGetDimensions( prhs[0] );

    trajData2 = (double*)mxGetPr( prhs[1] );
    dims2 = mxGetDimensions( prhs[1] );

    Trajectory traj1 = Trajectory( trajData1, dims1 );
    Trajectory traj2 = Trajectory( trajData2, dims2 );
    
    // Get weight
    if( nrhs >= 3 ) {
        weight_dims = mxGetDimensions( prhs[2] );
        if(!mxIsDouble(prhs[2]) || weight_dims[0] != 1 || weight_dims[1] != 2)
            mexErrMsgIdAndTxt( "MATLAB:errorfunc:inputNotDouble",
                    "Weight must be a 1x2 double.");
        
        weight = (double*)mxGetPr( prhs[2] );
        
        // Make sure it sums to 1, else normalise
        double weight_size = weight[0] + weight[1];
        if(weight_size != 1) {
            weight[0] = weight[0] / weight_size;
            weight[1] = weight[1] / weight_size;
        }
    } else {
        // default to even
        weight = (double*)malloc(2*sizeof(double));
        weight[0] = 0.5;
        weight[1] = 0.5;
        need_to_free = true;
    }
    
//     ijh::cout << "Weight: " << weight[0] << "," << weight[1] << std::endl;
//     ijh::mex_cout( );

    /* COMBINED MATCHING COST */
    matching_cost( Q, traj1, traj2, weight );
    plhs[0] = mxCreateDoubleMatrix( Q.rows, Q.cols, mxREAL );
    Q_output = mxGetPr( plhs[0] );
    Q.toDouble( Q_output );
    
    if( need_to_free ) {
        free( weight );
        weight = NULL;
    }
    
    /* DISTANCE COST */
    if( nlhs >= 2 ) {
        Matrix D;
        distance_cost( D, traj1, traj2 );
        plhs[1] = mxCreateDoubleMatrix( D.rows, D.cols, mxREAL );
        D_output = mxGetPr( plhs[1] );
        D.toDouble( D_output );
    }
    
    /* ANGLE COST */
    if( nlhs >= 3 ) {
        Matrix A;
        direction_cost( A, traj1, traj2 );
        plhs[2] = mxCreateDoubleMatrix( A.rows, A.cols, mxREAL );
        A_output = mxGetPr( plhs[2] );
        A.toDouble( A_output );
    }
    
}