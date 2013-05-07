
#include "mex.h"
#include "matrix.h"

#include <iostream>
#include <sstream>
#include <fstream>
#include "cameraModel.h"
#include "xmlUtil.h"
#include "../Matrix.hpp"
#include "../Trajectory.hpp"

#include "cameraModel.h"
#include "xmlUtil.h"

void mex_cout( std::stringstream *s ) {
    
    mexPrintf(s->str( ).c_str( ));
    s->str("");
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    mwSize buflen;

    
    /* check for proper number of arguments */
    if(nrhs!=2) 
      mexErrMsgTxt("Two inputs required - Video Path and Image Points.");
    else if(nlhs < 1 || nlhs > 4) 
      mexErrMsgTxt("Wrong number of output arguments: 1-4 required.");

    /* input must be a string */
    if ( mxIsChar(prhs[0]) != 1)
      mexErrMsgTxt("Input must be a string.");

    /* input must be a row vector */
    if (mxGetM(prhs[0])!=1)
      mexErrMsgTxt("Input must be a row vector.");

    /* get the length of the input string */
    buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;

    /* copy the string data from prhs[0] into a C string input_ buf.    */
    
    mexPrintf("Getting filename: \n");
    char *filename = mxArrayToString( prhs[0]);
    mexPrintf("Filename: %s\n", filename );
    
    Etiseo::CameraModel *cam = new Etiseo::CameraModel;
	
	Etiseo::UtilXml::Init();
	
    std::stringstream output;
    
	output << "******** CameraModel TEST  ********" << std::endl;
	mex_cout(&output);
    
    
	std::ifstream is;
	output << "Reading calibration from camera.xml ..." << std::endl;
	mex_cout(&output);
	is.open(filename);
	cam->fromXml(is);
	output << " done ..." << std::endl;
	mex_cout(&output);
	
    mxArray *cellPtr;
    double *cellDbl, *rotationDbl, *translationDbl, *focalDbl;
    mwSize num_trajectories;
    num_trajectories = mxGetNumberOfElements( prhs[1] );
    
    const mwSize *dims;
    
    // Output phase
    plhs[0]=mxCreateCellMatrix(num_trajectories, 1);
    
    for( int i = 0; i < num_trajectories; i++ ) {
        cellPtr = mxGetCell(prhs[1],i);
        cellDbl = mxGetPr( cellPtr );
        dims = mxGetDimensions( cellPtr );
        Trajectory t = Trajectory( cellDbl, dims );
        t.calibTsai( cam );
        
        mxArray *traj3D = mxCreateDoubleMatrix(3,t.length( ),mxREAL);
        double *traj3D_dbl = mxGetPr(traj3D);
        t.toDouble3D( traj3D_dbl );
        mxSetCell( plhs[0], i, traj3D );
    }

    Matrix rotation = Matrix(1,3);
    rotation.set(0,0,cam->rx( ));
    rotation.set(0,1,cam->ry( ));
    rotation.set(0,2,cam->rz( ));
    
    plhs[1] = mxCreateDoubleMatrix(1,3,mxREAL);
    rotationDbl = mxGetPr(plhs[1]);
    rotation.toDouble( rotationDbl );
    
    Matrix translation = Matrix(1,3);
    translation.set(0,0,cam->tx( ));
    translation.set(0,1,cam->ty( ));
    translation.set(0,2,cam->tz( ));
    
    plhs[2] = mxCreateDoubleMatrix(1,3,mxREAL);
    translationDbl = mxGetPr(plhs[2]);
    translation.toDouble( translationDbl );
    
    plhs[3] = mxCreateDoubleMatrix(1,1,mxREAL);
    focalDbl = mxGetPr(plhs[3]);
    focalDbl[0] = cam->focal( );
    
    return;
}