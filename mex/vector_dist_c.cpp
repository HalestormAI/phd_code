#include <cmath>
#include "mex.h"
#include "matrix.h"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    double  x0, // x coordinate 1, vector 1
            x1, // x coordinate 2, vector 2
            xdiff, // x-component of the distance
            y0,
            y1,
            ydiff,
            z0,
            z1,
            zdiff,
            *nums,  // Array representing points in vector 1
            *nums2; //      ----- || -----      in vector 2
    
    const mwSize *numDim,
                 *numDim2;
    
    // Sort out input data
    nums = (double*)mxGetPr(prhs[0]);
    numDim = mxGetDimensions(prhs[0]);
    
    // If we're working on 2 vectors
    if( nrhs == 2 ) {
        nums2 = (double*)mxGetPr(prhs[1]);
        numDim2 = mxGetDimensions(prhs[1]);
    } 
    
    int col_offset = (nrhs == 1 ? 2 : 1); // Skip a column if interlaced vector
    
    
    // Now output data
    plhs[0] = mxCreateDoubleMatrix(1,floor(numDim[1]/col_offset),mxREAL);
    double *outputDbl = mxGetPr( plhs[0] );
        
    for( int col=0; col < numDim[1]; col += col_offset) {
        x0 = nums[0+col*numDim[0]];
        y0 = nums[1+col*numDim[0]];
        if( nrhs == 1 ) { // If we're getting point-point distances from 1 vec
            x1 = nums[0+(col+1)*numDim[0]];
            y1 = nums[1+(col+1)*numDim[0]];
        } else if( nrhs == 2 ) { //  Otherwise comparing points between 2 vecs
            x1 = nums2[0+col*numDim[0]];
            y1 = nums2[1+col*numDim[0]];
        }

        xdiff = pow(x0-x1,2);
        ydiff = pow(y0-y1,2);

        if( numDim[0] == 3 ) { // If it's a 3D vector
            z0 = nums[2+col*numDim[0]];
            if( nrhs == 1 ) {
                z1 = nums[2+(col+1)*numDim[0]];
            } else if (nrhs == 2) {
                z1 = nums2[2+col*numDim[0]];
            }
            zdiff = pow(z0-z1,2);
        } else {
            zdiff=0;
        }
        

        outputDbl[(int)floor(col/(float)col_offset)] = sqrt(xdiff+ydiff+zdiff);

        if( nrhs == 1 && col + 2 >= numDim[1] ) {
            break;
        }
    }

}