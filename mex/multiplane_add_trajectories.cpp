#include "mex.h"
#include "matrix.h"
#include <vector>
#include <map>
#include <iterator>
#include <math.h>
#include <cstdlib>

#include "Plane.hpp"
#include "Point.hpp"
#include "SimTrajectory.hpp"
#include "functions.hpp"


#ifndef PI
#define PI 3.1415926535897932384626433832795028841971693993751058209749
#endif
#define DEG2RAD(DEG) ((DEG)*((PI)/(180.0)))


std::map<int,std::vector<float> > trajSpeeds;
std::map<int,std::vector<float> > trajDirections;

std::map<int,SimTrajectory> trajectories;
std::vector<Plane> planes;

float ENTER_PROB;

bool probabilityGenerator( float probability ) {
    float r = (float)std::rand( ) / (float)RAND_MAX;
    return r <= probability;
}

bool simulateFrame( int t ) {
    std::map<int,SimTrajectory>::iterator i;
    int num_finished = 0;
    for(i = trajectories.begin( ); i != trajectories.end( ); i++) {
//             mexPrintf("Checking trajectory\n"); mexEvalString("drawnow");
        if( i->second.isStarted( ) && !i->second.isFinished( ) ) {
        //     mexPrintf("Adding Frame\n"); mexEvalString("drawnow");
        
        //i->second.print3D( ); mexPrintf("\n\n");mexEvalString("drawnow");
             i->second.addFrame( &planes, t );
          //   mexPrintf("\tTrajectory is started but not finished\n");mexEvalString("drawnow");
        } else if( !i->second.isFinished( ) && probabilityGenerator( ENTER_PROB ) ) {
             mexPrintf("Starting trajectory\n"); mexEvalString("drawnow");
            i->second.start( t, &planes );
        } else if( i->second.isFinished( ) ) {
            ++num_finished;
        }
      //  mexPrintf("Loop end\n"); mexEvalString("drawnow");
    }
    
    return num_finished != trajectories.size( );
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    const mwSize *psz, *tsz;
    mxArray *mx_spds,*mx_drns, *mx_bounds, *mx_params;
    
    /* check proper input and output 
    if(nrhs!=2)
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidNumInputs",
                "5 inputs required.");
    else if(nlhs > 2)
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:maxlhs",
                "Too many output arguments.");
    else if(!mxIsDouble(prhs[0]))
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:inputNotStruct",
                "Input must be a double.");*/
    
    // Make plane instances using details from inputs 1&2 (plane boundaries and parameters).
    const mwSize *pbDims = mxGetDimensions( prhs[0] );
    const mwSize *ppDims = mxGetDimensions( prhs[1] );
    bool allSame = (pbDims[0] == ppDims[0]) && (pbDims[1] == ppDims[1]);
    if(!allSame)
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidSize",
                "Plane boundaries and parameters must be the same length.");
    
    int num_planes = std::max(pbDims[0],pbDims[1]);
    for( int p=0; p < num_planes; p++ ) {
        mx_bounds = (mxArray*) mxGetCell(prhs[0],p);
        mx_params = (mxArray*) mxGetCell(prhs[1],p);
        psz = mxGetDimensions( mx_bounds );
        planes.push_back(Plane( (double*)mxGetPr(mx_bounds), psz, (double*)mxGetPr(mx_params), planes.size( )));
//         planes.at(p).print( );
    }
    
    if( planes.empty( ) )
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:emptyPlanes",
                "Planes vector is empty. How very odd..." );
    
    // Create trajectory bases using speeds and directions from inputs 3 and 4.
    const mwSize *spdDims = mxGetDimensions( prhs[2] );
    const mwSize *drnDims = mxGetDimensions( prhs[3] );
    allSame = (spdDims[0] == drnDims[0]) && (spdDims[1] == drnDims[1]);
    if(!allSame)
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidSize",
                "Speeds and Directions must be the same length.");
    
    int num_traj = std::max(spdDims[0],spdDims[1]);
    int num_frames;
    
    mexPrintf("Num: %d, [%d.%d]\n",num_traj, spdDims[0], spdDims[1]);
    for( int t=0; t < num_traj; t++ ) {
        mx_spds = (mxArray*) mxGetCell(prhs[2],t);
        mx_drns = (mxArray*) mxGetCell(prhs[3],t);
        tsz = mxGetDimensions( mx_spds );
        num_frames = std::max(tsz[0],tsz[1]);
        trajectories[t] = SimTrajectory( (double*)mxGetPr(mx_spds), (double*)mxGetPr(mx_drns), tsz );
    }
    
    if( nrhs >= 5 )
        ENTER_PROB = *((float*)mxGetPr(prhs[4]));
    else
        ENTER_PROB = 1;
    

    for( int frame = 0; frame < num_frames; frame++ ) {
        //mexPrintf("Running Frame %d of %d\n",frame, num_frames);
        if(!simulateFrame(frame))
            break;
    }
    
    
    // OUTPUT PHASE
    mexPrintf("Outputting\n");mexEvalString("drawnow");
    plhs[0]=mxCreateCellMatrix(num_traj, 1);
    
    std::map<int,SimTrajectory>::iterator i;
    int cellCount = 0;
    for(i = trajectories.begin( ); i != trajectories.end( ); i++) {
        mxArray *traj3D = mxCreateDoubleMatrix(3,i->second.length( ),mxREAL);
        double *traj3D_dbl = mxGetPr(traj3D);
        i->second.toDouble3D( traj3D_dbl );
        mxSetCell( plhs[0], cellCount++, traj3D );
//         i->second.print3D();
    }
}

    

