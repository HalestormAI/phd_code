#include <cmath>
#include "mex.h"
#include "matrix.h"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
 
    double *nums = (double*)mxGetPr(prhs[0]);
    
    const mwSize *numDim = mxGetDimensions(prhs[0]);
    
    
    plhs[0] = mxCreateDoubleMatrix(1,floor(numDim[1]/2),mxREAL);
    
    double *outputDbl = mxGetPr( plhs[0] );
    
    
    double x0,x1,xdiff,y0,y1,ydiff,z0,z1,zdiff;
    
    for( int col=0; col < numDim[1]; col+=2 ) {
        x0 = nums[0+col*numDim[0]];
        y0 = nums[1+col*numDim[0]];
        
        x1 = nums[0+(col+1)*numDim[0]];
        y1 = nums[1+(col+1)*numDim[0]];
        
        xdiff = pow(x0-x1,2);
        ydiff = pow(y0-y1,2);
        
        if( numDim[0] == 3 ) {
            z0 = nums[2+col*numDim[0]];
            z1 = nums[2+(col+1)*numDim[0]];
            zdiff = pow(z0-z1,2);
        } else
            zdiff=0;
        
        
        outputDbl[(int)floor(col/2.0)] = sqrt(xdiff+ydiff+zdiff);
        
        if( col + 2 >= numDim[1] ) {
            break;
        }
    }
}