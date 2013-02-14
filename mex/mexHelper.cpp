#include "mex.h"
#include "matrix.h"
#include <sstream>
#include <vector>

namespace ijh
{
    
    std::stringstream cout; /*!< Stream to allow for psuedo std::cout */
    
    /** 
     * Converts an STL double vector into an mxArray for output to Matlab.
     *
     * N.B. The mxArray must have been created using mxCreateDoubleMatrix
     *      before calling this function.
     *
     * 
     * @param[in]    vec     The vector for conversion
     * @param[out]   arr     A pointer to the mxArray
     */
    template <class T>
    void vector2mxArray( const std::vector<T> &vec, mxArray *arr )
    {
        double *arr_dbl= mxGetPr(arr);
        typename std::vector<T>::const_iterator it;
        int i = 0;
        
        for( it = vec.begin( ); it != vec.end( ); it++ )
        {
            arr_dbl[i++] = *it;
        }
        
    }  
    /** 
     * Converts an mxArray into an STL double vector.
     *
     * N.B. Must be a 1xn or 1xn vector!
     * 
     * @param[in]    arr     The mxAray pointer for conversion
     * @param[out]   vec     The vector to be filled
     */
    template <class T>
    void mxArray2vector( const mxArray *arr , std::vector<T> &vec)
    {
        bool isrow;
        double *arr_dbl= mxGetPr(arr);
        const mwSize *dims = mxGetDimensions( arr );
        
        if( dims[0] == 1 ) {
            isrow = true;
        } else if( dims[1] == 1 ) {
            isrow = false;
        } else {
            mexErrMsgIdAndTxt( "MATLAB:ijh:notvec",
                    "Input is not a vector.");
        }
        
        for( int i = 0; i < (isrow ? dims[1] : dims[0]); i++ )
        {
            vec.push_back( arr_dbl[i] );
        }
        
    }  
    
    /**
     * Used to output pseudo-cout. 
     *
     * Optionally, can be used to send any stringstream to Matlab stdout
     * 
     * Must be called at least once to display
     * desired content. Outputs to Matlab and flushes the buffer maintained
     * in ijh::cout.
     *
     * @param[in out]   strm    A pointer to the stringstream to be printed (optional)
     */
    void mex_cout( std::stringstream *strm = 0 )
    {
        if( !strm )
            strm = &cout;
        mexPrintf(strm->str( ).c_str( ));
        strm->str(std::string());
    }
    
    
    template <class T>
    void printVector( std::vector<T> &vec )
    {
        typename std::vector<T>::iterator it;

        ijh:: cout << "[ ";
        for( it = vec.begin( ); it != vec.end( ); it++ )
        {
            ijh::cout << *it << " ";
        }
        ijh::cout << "]" << std::endl;
    }

}