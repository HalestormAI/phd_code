#include "mex.h"
#include "matrix.h"
#include <vector>
#include "mexHelper.cpp"


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
 
    const mwSize *dims;
    double *arr;
    bool isrow;
    
    
    arr = mxGetPr( prhs[0] );
    dims = mxGetDimensions( prhs[0] );
    
    if( dims[0] == 1 ) {
        isrow = true;
    } else if( dims[1] == 1 ) {
        isrow = false;
    } else {
        mexErrMsgIdAndTxt( "MATLAB:ijh:notvec",
                "Input is not a vector.");
    }
    
    
    // Run through vector, split into consecutive blocks
    std::vector< std::vector<double> > all_vecs;
    std::vector<double> current;
    current.push_back(arr[0]);
    
    std::vector< std::vector<int> > all_vec_ids;
    std::vector<int> current_ids;
    current_ids.push_back(1);
    
    
    for( int i=1; i< (isrow ? dims[1] : dims[0]); i++ )
    {
        // If arr[i] == arr[i-1]+1, we're still consecutive
        // Otherwise, end this vector and append to collection
        if( arr[i] != arr[i-1]+1 ) {
            all_vecs.push_back(current);
            all_vec_ids.push_back(current_ids);
            // Now clear it and start anew
            current.clear( );
            current_ids.clear( );
        }
        
        current.push_back(arr[i]);
        current_ids.push_back(i+1);
    }
    
    all_vecs.push_back(current);
    all_vec_ids.push_back(current_ids);
    
    
    // Output raw data
    plhs[0] = mxCreateCellMatrix(all_vecs.size( ),1);
    uint cell_count = 0;
    std::vector< std::vector<double> >::iterator it;
    for( it = all_vecs.begin( ); it != all_vecs.end( ); it++ )
    {
        mxArray *tmp = mxCreateDoubleMatrix(1,(*it).size( ),mxREAL);
        ijh::vector2mxArray<double>( *it, tmp );
        mxSetCell( plhs[0], cell_count++, tmp );
    }
    
    // Output ids
    plhs[1] = mxCreateCellMatrix(all_vec_ids.size( ),1);
    cell_count = 0;
    std::vector< std::vector<int> >::iterator it_ids;
    for( it_ids = all_vec_ids.begin( ); it_ids != all_vec_ids.end( ); it_ids++ )
    {
        mxArray *tmp = mxCreateDoubleMatrix(1,(*it_ids).size( ),mxREAL);
        ijh::vector2mxArray<int>( *it_ids, tmp );
        mxSetCell( plhs[1], cell_count++, tmp );
    }
    
    
    
}