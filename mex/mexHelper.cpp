#ifndef MEXHELPER_CPP
#define MEXHELPER_CPP 1

#include "mexHelper.hpp"

namespace ijh {
   std::stringstream cout; /*!< Stream to allow for psuedo std::cout */
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
void ijh::mex_cout( std::stringstream *strm )
{
    if( !strm )
        strm = &cout;
    mexPrintf(strm->str( ).c_str( ));
    strm->str(std::string());
}

/**
 * More memorable wrapper for sending a mex error message
 *
 * @param[in] message   The error message to be relayed to Matlab
 */
void ijh::error( const std::string message )
{
    mexErrMsgTxt( message.c_str( ) );
}


/**
 * Constructor for all values provided as ints
 */
ijh::check_io::check_io( int i_min, int i_max, int o_min, int o_max )
{
    this->input  = IO( i_min, i_max );
    this->output = IO( o_min, o_max );
}

/**
 * Constructor to allow the use of STL pairs, one for input, one for
 * output
 */
ijh::check_io::check_io( std::pair<int,int> i, std::pair<int,int> o )
{
    this->input  = IO( i.first, i.second );
    this->output = IO( o.first, o.second );
}

/**
 * Constructor where there are fixed numbers of inputs (i.e. not
 * min/max). 
 */
ijh::check_io::check_io( int i, int o )
{
    this->input  = IO( i, i );
    this->output = IO( o, o );

}

/**
 * Check input and output
 */
bool ijh::check_io::check( int i, int o )
{
    if( !(this->input.check( i ) && this->output.check( o )) )
    {
        std::stringstream strm;
        strm << "Invalid parameters provided - " << i << ", " << o;
        strm << "\n\tInput: " << input.min( );
        strm << "-" << input.max( ) << "\n\tOutput: " << output.min( );
        strm << "-" << output.max( ) << std::endl;
        ijh::error(strm.str( ));
    };
    return true;
}

#endif