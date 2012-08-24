#include "mex.h"
#include "matrix.h"
#include <vector>
#include <iterator>
#include <string.h>
#include "Point.hpp"
#include "Trajectory.hpp"
#include "Matrix.hpp"

#ifndef DEG2RAD
#define DEG2RAD(DEG) (((DEG)*PI)/(180.0))
#define RAD2DEG(RAD) ((RAD)*180.0/PI)
#endif

class Hypothesis
{
public:
    double theta;
    double psi;
    double foc;
    
    mxArray *inputs[3];
    
    Hypothesis( double t, double p, double f )
    {
        this->theta = t;
        this->psi = p;
        this->foc = f;

        this->inputs[0] = mxCreateDoubleMatrix( 1, 2, mxREAL );
        this->inputs[1] = mxCreateDoubleMatrix( 1, 2, mxREAL );


        // Build inputs for errorfunc
        double orientation[] = { this->theta, this->psi };
        memcpy((double*)mxGetPr(inputs[0]), orientation, 2 * sizeof(double) );

        double scales[] = { 1, this->foc };
        memcpy((double*)mxGetPr(inputs[1]), scales, 2 * sizeof(double) );
        
    }
    
    mxArray* getInputs( ) {
        return this->inputs;
    }
    
    static std::vector<Hypothesis> loadHypotheses( const mxArray *hyparr )
    {
        std::vector<Hypothesis> hypotheses;
        
        double theta, psi, foc;
        
        int rows = mxGetM( hyparr );
        
        double *data = mxGetPr( hyparr );
        
            
        for( int row = 0; row < rows; row++ ) {
            theta = data[row+0*rows];
            psi   = data[row+1*rows];
            foc   = data[row+2*rows];
            Hypothesis H = Hypothesis( theta, psi, foc );
            hypotheses.push_back( H );
            mexPrintf( "Hypothesis: %4g, %4g, %4g\n", theta, psi, foc ); mexEvalString("drawnow");
        }
        return hypotheses;
    }
};

void line_side( Point line_centre, double line_angle, Trajectory *traj, bool *sides )
{
    double line_m = tan( DEG2RAD(line_angle) );
    double line_c = line_centre.y - line_centre.x*line_m;
    
    double error;
    
    for( int p = 0; p < traj->length( ); p++ )
    {
        error = line_m*traj->points.at(p).x + line_c - traj->points.at(p).y;
        sides[p] = (error >= 0);
    }
}

// Should split a vector into consecutive blocks
void split_vec( bool *in, 
                int inLength, 
                std::vector< std::vector<double> > *splits,
                std::vector< std::vector<int> > *splitIds )
{
    std::vector<double> currentSplit;
    std::vector<int> currentIds;
    
    // Start it off with the beginning of the array
    currentSplit.push_back( in[0] );
    currentIds.push_back( 0 );
    
    for(int i = 1; i < inLength; i++ ) {
        if( in[i] != in[i-1] ) 
        // if different, copy vectors to splits and splitIds then clear before copying values to curr
        {
            splits->push_back( currentSplit );
            splitIds->push_back( currentIds );
            
            currentSplit.clear( );
            currentIds.clear( );
        }
        
        currentSplit.push_back( in[i] );
        currentIds.push_back( i );
    }
    
    // One last time to finish it off
    splits->push_back( currentSplit );
    splitIds->push_back( currentIds );
}

void split_trajectories_for_line (
                      std::vector<Trajectory> trajectories,
                      Point centre,
                      double angle,
                      std::map< int, std::vector<Trajectory> > *sideTrajectories )
{
    std::vector<Trajectory>::iterator i;
    std::vector< std::vector<double> > splits;
    std::vector< std::vector<int> > splitIds;
    
    for( i = trajectories.begin( ); i != trajectories.end( ); i++ )
    {
        bool sides[ i->length( ) ];
        line_side( centre, angle, &(*i), sides );
        
        split_vec( sides, i->length( ), &splits, &splitIds );
        
        std::vector<double>::iterator sIt;
        std::vector<int>::iterator sIt2;
        
        for( int s = 0; s < splits.size( ); s++ )
        {
            
            int side = splits.at(s).at(0);
            std::vector<Trajectory> *vec = &((*sideTrajectories)[side]);
            
            vec->push_back( i->subtrajectory( splitIds.at(s) ) );
        }
        
        splits.clear( );
        splitIds.clear( );
    }
}


std::vector<Point> getLinePoints( double *points, const mwSize *dims ) {
    std::vector<Point> linePoints;

    double x,y;
    for(int col=0;col < dims[1]; col++) {
        x = points[0+col*dims[0]];
        y = points[1+col*dims[0]];
        linePoints.push_back( Point( x, y ) );
    }
    
    return linePoints;
}

Matrix getError( std::vector<Trajectory> *traj, mxArray *inputs[] )
{
    mxArray *outputs[3];
    
    
//     mexPrintf("\tOutputting Trajectories\n");mexEvalString("drawnow");
    Trajectory::outputAll( traj, inputs[2] );
    
//     mexPrintf("\tTrajs done, entering errorfunc\n");mexEvalString("drawnow");
    mexCallMATLAB( 3, outputs, 3, inputs, "errorfunc_traj" );
//     mexPrintf("\tReturning\n");mexEvalString("drawnow");

    mxArray *mx_errors = outputs[0];
    double *errors = (double*)mxGetPr( mx_errors );
    const mwSize *errSize = mxGetDimensions( mx_errors );

    Matrix errorMat = Matrix( errSize[0], errSize[1] );
    errorMat.fromDouble( errors );
    
    return errorMat;
            
}


double errorForHypothesis( std::vector<Trajectory> traj,
                           Hypothesis hypothesis )
{
    mxArray *inputs;
    double err;
    
    bool suitable = 0;
    
    for( int t=0; t < traj.size( ); t++ )
    {
        if( traj.at(t).length( ) > 3 )
            suitable = 1;
    }

    
    if( traj.size( ) > 0 && suitable == 1 ) {
        inputs = hypothesis.getInputs( traj.size( ) );
        
        Matrix err_mat = getError( &traj, inputs );
        err = pow(&err_mat,2).sum( );
    } else {
        err = 999999;
    }
    return err;
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    
    
    double *angles;
    std::vector<Trajectory> allTraj;
    std::vector<Hypothesis> hypotheses;
    const mwSize *trajDim;
    int numAngles;
   
    
    //check proper input and output 
    if( nrhs != 4 )
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidNumInputs",
                "4 inputs required: \n\t <Trajectories>, <hypotheses>, <linePoints>, <angles>.");
    else if( nlhs > 2 )
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:maxlhs",
                "Too many output arguments, see below: \n\t [<errors_1>, <errors_2>].");
    
    
    // Load trajectories
//     mexPrintf("Loading Trajectories\n");mexEvalString("drawnow");
    Trajectory::loadAll( prhs[0], &allTraj );
    trajDim = mxGetDimensions( prhs[0] );
    
//     mexPrintf("Loading Hypotheses\n");mexEvalString("drawnow");
    hypotheses = Hypothesis::loadHypotheses( prhs[1] );
    
//     mexPrintf("Loading linePoints\n");mexEvalString("drawnow");
    std::vector<Point> linePoints;
    linePoints = getLinePoints( (double*)mxGetPr(prhs[2]), mxGetDimensions( prhs[2] ) );
    
//     mexPrintf("Loading angles\n");mexEvalString("drawnow");
    angles = (double*)mxGetPr( prhs[3] );
    numAngles = mxGetN( prhs[3] );
    
    // Now loop over points and angles
    
    Matrix errors_1 = Matrix( linePoints.size( ), numAngles );
    Matrix errors_2 = Matrix( linePoints.size( ), numAngles );
    
    
//     mexPrintf("Looping\n");mexEvalString("drawnow");
    for( int l = 0; l < linePoints.size( ); l++ )
    {
                
        for( int a = 0; a < numAngles; a++ )
        {
            
//             mexPrintf( "\tAngle: %g\n", angles[a]);
            // Split trajectories
            std::map< int, std::vector<Trajectory> > sideTrajectories;
            split_trajectories_for_line ( allTraj, linePoints.at(l), angles[a], &sideTrajectories );
            
            double err1 = errorForHypothesis(sideTrajectories[0], hypotheses.at(0)) + 
                          errorForHypothesis(sideTrajectories[1], hypotheses.at(1));
            
            double err2 = errorForHypothesis(sideTrajectories[1], hypotheses.at(0)) + 
                          errorForHypothesis(sideTrajectories[0], hypotheses.at(1));
            
            // Send hypotheses and 1 side of trajectories
            errors_1.set(l,a, err1);
            errors_2.set(l,a, err2);
            
        }
        
        mexPrintf( "Done %d of %d...\n", l, linePoints.size( ) );
        
    }
    
    // Now simply return errors 1 and 2
    double *err1dbl, *err2dbl;
    plhs[0] = mxCreateDoubleMatrix( errors_1.rows, errors_1.cols, mxREAL );
    err1dbl = mxGetPr( plhs[0] );
    errors_1.toDouble( err1dbl );
    
    plhs[1] = mxCreateDoubleMatrix( errors_2.rows, errors_2.cols, mxREAL );
    err2dbl = mxGetPr( plhs[1] );
    errors_2.toDouble( err2dbl );
}