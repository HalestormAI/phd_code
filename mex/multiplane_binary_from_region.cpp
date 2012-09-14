#include "mex.h"
#include "matrix.h"
#include <math.h>
#include <string>

void mexOut( std::string str )
{
    mexPrintf( str.c_str( ) );
    mexEvalString("drawnow");
}

/**
 * Euclidean distance calculation
 *
 * INPUT:
 *  x0, y0  The first point
 *  x1, y1  The second point
 *
 * OUTPUT:
 *  The euclidean distance between [x0,y0] and [x1,y1]
 */
double euclid_dist( int x0, int x1, int y0, int y1 )
{
    return sqrt( pow(x0-x1,2) + pow(y0-y1,2) );
}

/**
 * Zero fills a Matlab double matrix
 *
 * INPUT:
 *  outImg  Pointer to the image
 *  rows    Number of rows in the image
 *  cols    Number of columns in the image
 */
void zero_fill( double *outImg, int rows, int cols )
{
    int row, col, index;
    for( row = 0; row < rows; row++ ) {
        for( col = 0; col < cols; col++ ) {
            index = row + col*rows; 
//             mexPrintf(  "\tSetting (%d,%d) [%d] - max: %d\n", row, col, index,rows*cols );
//             mexEvalString("drawnow");
            outImg[index] = 0;
        }
    }
}

/**
 * Colours pixels if they're within a circle
 *
 * INPUT:
 *  radius      The circle radius
 *  centre      The circle centre
 *  outImg      Pointer to the Matlab double array for the image
 */
void colour_pixels( double *radius, double *centre, double *outImg, int rows, int cols )
{
    
    int x, y, min_x, min_y, max_x, max_y, row, col, index;
    
    // Set up boundaries to minimise the number of pixels we check
    mexOut( "\t\tGetting Vars\n" );
    min_x = centre[0] - *radius;
    max_x = centre[0] + *radius;
    
    min_y = centre[1] - *radius;
    max_y = centre[1] + *radius;
    
    mexOut( "\t\tBeginning Inner Loop\n" );
    for( x = min_x; x <= max_x; x++ ) {
        if( x >= cols ) { // sanity check
            mexPrintf("\t\t\tx is too big: %d (max: %d)\n", x, cols);
            mexEvalString("drawnow");
            continue;
        }
        for( y = min_y; y <= max_y; y++ ) {
            if( y >= rows ) { // sanity check
                mexPrintf("\t\t\ty is too big: %d (max: %d)\n", y, rows);
                mexEvalString("drawnow");
                continue;
            }
            index = y + x*rows; 
            
            double dist = euclid_dist( x, centre[0], y, centre[1] );
            
            if( dist <= *radius ) {
                outImg[index] = 1;
            } else {
//                 mexPrintf("\t\t\tToo far: (%d,%d) -> (%g,%g)\n", x,y, centre[0],centre[1]);
//                 mexEvalString("drawnow");
            }
                
        }
    }
}

/**
 * Input:
 *  regions     A struct of regions (pre-filtered for label)
 *  img_dims    A 2x1 array holding x_max and y_max
 *
 * Output:
 *  img         A binary image with regions highlighted.
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
 
    mexOut( "Setting init vars\n" );
    const mxArray *regions, *img_dims;
    mxArray *mx_outImg, *mx_radius, *mx_centre;
    double *outImg, *img_dims_dbl, *radius, *centre;
    int x, y, max_x, max_y;
    
    // Take in regions for label as argument 1
    mexOut( "Getting Regions\n" );
    regions = prhs[0];
    
    mexOut( "Getting Number of Regions: " );
    mwSize num_regions = mxGetM( regions );
    
    mexPrintf(  "%d\n", num_regions );
    mexEvalString("drawnow");

    // Create a blank image
    mexOut( "Getting Image Dimensions: " );
    img_dims = prhs[1];
    img_dims_dbl = (double*)mxGetPr(img_dims);
    
    max_x = img_dims_dbl[0];
    max_y = img_dims_dbl[1];
    mexPrintf(  "(%d, %d)\n", max_x, max_y );
    mexEvalString("drawnow");
    
    mx_outImg = mxCreateDoubleMatrix( max_y, max_x, mxREAL );
    outImg = (double*)mxGetPr( mx_outImg );
    
    mexPrintf(  "Zero Filling: (%d, %d)\n", max_y, max_x );
    mexEvalString("drawnow");
    zero_fill( outImg, max_y, max_x );
    
    mexOut( "Beginning loop\n" );
    // For each region, colour pixels within its area
    for( int r=0; r < num_regions; r++ )
    {
        mexPrintf(  "\tGetting radius & centre (Region %d)\n",r );
        mexEvalString("drawnow");
        mx_radius = mxGetField( regions, r, "radius" );
        mx_centre = mxGetField( regions, r, "centre" );
        
        radius = (double*)mxGetPr(mx_radius);
        centre = (double*)mxGetPr(mx_centre);
        centre[0] = round(centre[0]);
        centre[1] = round(centre[1]);
        *radius = round(*radius);
        mexPrintf(  "\t\tRadius: %g\n", *radius );
        mexPrintf(  "\t\tCentre: (%g, %g)\n", centre[0], centre[1] );
        mexEvalString("drawnow");
        
        mexOut( "\tColouring Pixels\n" );
       colour_pixels( radius, centre, outImg, max_y, max_x );
    }
    
    // Output image
    plhs[0] = mx_outImg;
}