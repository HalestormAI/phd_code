#include "mex.h"
#include "matrix.h"
#include <vector>
#include <iterator>
#include "Point.hpp"
#include "Trajectory.hpp"
#include "Matrix.hpp"


void trajForRegion( std::vector<Trajectory> *traj, Point centre, double window_size, std::vector<Trajectory> *out ) {
    std::vector<Trajectory>::iterator t;
    for( t = traj->begin( ); t != traj->end( ); t++ ) {
        Trajectory tr = Trajectory( );
        for( int p = 0; p < t->length( ); p++ ) {
            
            double dist = centre.dist2D( t->at(p) );
            
            if( dist <= window_size )
                tr.addPoint( t->at(p) );
        }
        if( tr.length( ) )
            out->push_back(tr);
    }
    
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    
    
    double *mxd_minmax;
    mxArray *mx_centre, *mx_radius, *mx_trajs;
    double window_size,step_size,x,y;
    const char **fnames;
    Point ctr;
    std::vector<Trajectory> alltraj;
    std::vector<std::vector<Trajectory> > regionTraj;
    const mwSize *trajDim;
    
    
    //check proper input and output 
    if(nrhs<2)
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidNumInputs",
                "minimum 2 inputs required.");
    else if(nlhs > 2)
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:maxlhs",
                "Too many output arguments.");
    
    
    std::vector<Point> centres;
   
    Matrix minmax = Matrix(2,2);
    mxd_minmax = (double*)mxGetPr(prhs[0]);
    minmax.fromDouble( mxd_minmax );
    
    
    window_size = *((double*)mxGetPr(prhs[1]));
    
    y = minmax.at(1,0);
    
    if( nrhs < 4 )
        step_size = window_size/2;
    else
        step_size = *((double*)mxGetPr(prhs[3]));
    
    // Load trajectories
    mexPrintf("Loading Trajectories\n");mexEvalString("drawnow");
    if( nrhs >= 3 ){
        Trajectory::loadAll( prhs[2], &alltraj );
    }
    
    // Create regions
    mexPrintf("Create regions\n");mexEvalString("drawnow");
    while( y < minmax.at(1,1) ) {
        x = minmax.at(0,0);
        while( x < minmax.at(0,1) ) {
            ctr = Point( x, y );
            centres.push_back( ctr );
            
            // Sort out trajectories
            if( nrhs >= 3 ) {
                std::vector<Trajectory> t;
                trajForRegion( &alltraj, ctr, window_size, &t );
                regionTraj.push_back( t );
            }
            x += step_size;
        }
        y += step_size;
    }
    
    
    // Begin output
    mexPrintf("Begin output\n");mexEvalString("drawnow");
    fnames = (const char**)mxCalloc(3, sizeof(*fnames));
    const char fn1[] = "centre";
    const char fn2[] = "radius";
    const char fn3[] = "traj";
    
    fnames[0] = fn1;
    fnames[1] = fn2;
    if( nrhs >= 3 ){
        const char fn3[] = "traj";
        fnames[2] = fn3;
    }
    
    plhs[0] = mxCreateStructMatrix(centres.size( ), 1, 3, fnames);
    mxFree((void *)fnames);
    
    
    for(int i=0; i<centres.size( ); i++) {
//         mexPrintf("\tOutput centre %d\n",i);mexEvalString("drawnow");
        mx_centre = mxCreateDoubleMatrix(2,1,mxREAL);
        centres.at(i).toMatrix( ).toDouble( mxGetPr(mx_centre) );
        
        mx_radius = mxCreateDoubleMatrix(1,1,mxREAL);
        *(mxGetPr(mx_radius)) = window_size;
        
        mxSetFieldByNumber(plhs[0], i, 0, mx_centre);
        mxSetFieldByNumber(plhs[0], i, 1, mx_radius);
        
//     mexPrintf("\tOutput traj %d\n",i);mexEvalString("drawnow");
        if( nrhs >= 3 ){
            // TODO: Populate mx_traj
            mx_trajs = mxCreateCellMatrix(regionTraj.at(i).size( ), 1);
            
            std::vector<Trajectory>::iterator j;
            int cellCount = 0;
            for( j=regionTraj.at(i).begin( ); j != regionTraj.at(i).end( ); j++ ) {
                mxArray *mx_traj = mxCreateDoubleMatrix(2,j->length( ),mxREAL);
                double *mxd_traj = mxGetPr(mx_traj);
                j->toDouble2D( mxd_traj );
                mxSetCell( mx_trajs, cellCount++, mx_traj );
            }
            
            mxSetFieldByNumber(plhs[0], i, 2, mx_trajs);
        }
    }   
    
}