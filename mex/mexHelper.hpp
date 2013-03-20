#ifndef MEXHELPER
#define MEXHELPER 1

#include "mex.h"
#include "matrix.h"
#include <sstream>
#include <vector>
#include <map>

namespace ijh
{
    
    extern std::stringstream cout; /*!< Stream to allow for psuedo std::cout */
    
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
    void mex_cout( std::stringstream *strm = 0 );
    
    /**
     * More memorable wrapper for sending a mex error message
     *
     * @param[in] message   The error message to be relayed to Matlab
     */
    void error( const std::string message );
    
    /**
     * Get all keys from an STL map as STL vector
     *
     * @param[in]   m       Input map of type <T,U>
     * @return      k       Vector of keys with type T
     */
    template< class T, class U >
    std::vector<T> map_keys( const std::map<T, U> &m )
    {
        typename std::map<T,U>::const_iterator i;
        typename std::vector<T> k;
        
        for( i=m.begin( ); i != m.end( ); i++ )
        {
            k.push_back( i->first );
        }
        
        return k;
    }
    
    
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
     * Print an STL vector
     */
    template <class T>
    void printVector( const std::vector<T> &vec )
    {
        typename std::vector<T>::const_iterator it;

        ijh::cout << "[ ";
        for( it = vec.begin( ); it != vec.end( ); it++ )
        {
            ijh::cout << *it << " ";
        }
        ijh::cout << "]" << std::endl;
    }
    
    
    /**
     * Check nrhs/nlhs against known numbers
     * 
     * Feed it the expected values and then check them using a separate
     * method.
     */ 
    class check_io
    {
        public:
            check_io( ) {};
            check_io( int i_min, int i_max, int o_min, int o_max );
            check_io( std::pair<int,int> i, std::pair<int,int> o );            
            check_io( int i, int o );

            bool check( int i, int o );

        private:
            class IO {
                public:
                    IO () {}
                    IO( int min, int max )
                    {
                        this->setExpected(min,max);
                    }

                    bool check( int n )
                    {
                        return n <= this->_max && n >= this->_min;
                    }

                    void setExpected( int min, int max )
                    {
                        if( min > max ) {
                            ijh::error("Invalid Range Provided:");
                        }
                        this->_min  = min;
                        this->_max  = max;
                    }

                    int min( ) { return _min; }
                    int max( ) { return _max; }
                private:
                    int _min;
                    int _max;
            };

            IO input;
            IO output;
        
    };

}

#endif
