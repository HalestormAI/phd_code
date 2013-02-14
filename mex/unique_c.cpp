#include "mex.h"
#include "matrix.h"
#include <vector>
#include <sstream>
#include <algorithm>
#include "mexHelper.cpp"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    
    std::vector<double> vec;
    std::vector<double>::iterator it;
    
    // Convert input data to vector
    ijh::mxArray2vector( prhs[0], vec );
    
    // Sort, get unique and resize
    std::sort(vec.begin( ), vec.end( ));
    it = std::unique(vec.begin( ), vec.end( ));
    vec.resize( std::distance(vec.begin( ), it) );
    
    plhs[0] = mxCreateDoubleMatrix( vec.size( ), 1, mxREAL );
    ijh::vector2mxArray( vec, plhs[0] );
   
}