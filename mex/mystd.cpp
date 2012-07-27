#include <cmath>
#include "mex.h"
#include "matrix.h"


double _mean ( double* nums, int row, const mwSize *dims )
{
    double rowSum = 0;
    for( int col=0; col < dims[1] ; col++ ) {
        rowSum += nums[row+col*dims[0]];
    }
    
    return rowSum / dims[1];
}

double _ssd( double* nums, int row, const mwSize *dims, double mean ) {
    
    double sumsqdiff = 0;
    for( int col=0; col < dims[1] ; col++ ) {
        sumsqdiff += pow(nums[row+col*dims[0]] - mean,2);
    }
    
    return sumsqdiff;
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
 
    double *nums = (double*)mxGetPr(prhs[0]);
    
    const mwSize *numDim = mxGetDimensions(prhs[0]);
    
    
    plhs[0] = mxCreateDoubleMatrix(numDim[0],1,mxREAL);
    
    double *outputDbl = mxGetPr( plhs[0] );
    
    int n = numDim[1];
    for( int row=0; row < numDim[0]; row++ ) {
        double row_mn = _mean( nums, row, numDim );
        double ssd    = _ssd( nums, row, numDim, row_mn );
        outputDbl[row] = sqrt( (1.0/(n-1)) *ssd );
    }
}