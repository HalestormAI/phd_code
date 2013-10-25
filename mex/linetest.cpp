#include "mex.h"
#include "matrix.h"
#include <vector>
#include "Point.hpp"
#include "Line.cpp"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    const mwSize *psz, *tsz;
    double *lines1dbl, *lines2dbl;
    
    lines1dbl = mxGetPr(prhs[0]);
    lines2dbl = mxGetPr(prhs[0]);
    
    psz = mxGetDimensions( prhs[0]);
    std::vector<Line> lines1, lines2;
    
    
    // Load in
    for( int i=0; i < 4; i+=2 ) {
        Point start(lines1dbl[i],lines1dbl[i+4],lines1dbl[i+8]);
        Point end(lines1dbl[i+1],lines1dbl[i+5],lines1dbl[i+9]);
        
        lines1.push_back( Line(start, end) );
        Point start2(lines2dbl[i],lines2dbl[i+4],lines2dbl[i+8]);
        Point end2(lines2dbl[i+1],lines2dbl[i+5],lines2dbl[i+9]);
        
        lines2.push_back( Line(start2, end2) );
    }
    
    // Check for intersects
    for(unsigned int l=0; l < lines1.size( ); l++ ) 
    {
        for( unsigned int l2=0; l2 < lines2.size( ); l2++ )
        {
            Line l11 = lines1.at(l),
                 l12 = lines2.at(l2);
            
            double d = l11.point_distance(l12.start);
            if(d < 0.001) {
                mexPrintf("Line1 %d and line2 %d are the same (d=%g).\n", l,l2,d);
                l11.print( );
                l12.print( );
            } else {
                mexPrintf("Line1 %d and line2 %d are NOT the same (d=%g).\n", l,l2,d);
                l11.print( );
                l12.print( );
            }
            
        }
     }
    
    
    
}