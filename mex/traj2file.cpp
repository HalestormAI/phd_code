#include "mex.h"
#include "matrix.h"
#include "Trajectory.hpp"


    
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{

    const mwSize *dims1, *dims2;
    double *trajData1, 
           *trajData2,
           *output1,
           *output2;

    trajData1 = (double*)mxGetPr( prhs[0] );
    dims1 = mxGetDimensions( prhs[0] );

    trajData2 = (double*)mxGetPr( prhs[1] );
    dims2 = mxGetDimensions( prhs[1] );

    Trajectory traj1 = Trajectory( trajData1, dims1 );
    Trajectory traj2 = Trajectory( trajData2, dims2 );
    
    
    traj1.toFile("/home/csunix/sc06ijh/PhD/traj1.txt");
    traj2.toFile("/home/csunix/sc06ijh/PhD/traj2.txt");
}