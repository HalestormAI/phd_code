#include "matrix.h"
#include "mex.h"
#include "string.h"
#include <string>
#include <iostream>
#include <vector>
#include "Plane.hpp"

#define MAXCHARS 80   /* max length of string contained in each field */

std::string get_mex_string( const mxArray *string_array_ptr )
{
    char *buffer;
    mwSize buffer_length;
    
    // Allocate buffer memory
    buffer_length = mxGetNumberOfElements(string_array_ptr) + 1;
    buffer = (char*)mxCalloc(buffer_length, sizeof(char));
    
    if (mxGetString(string_array_ptr, buffer, buffer_length) != 0)
        mexErrMsgIdAndTxt( "MATLAB:explore:invalidStringArray",
            "Could not convert string data.");
    
    std::string output(buffer);
    return output;

}

/*  the gateway routine.  */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{

        mwSize NStructElems = mxGetNumberOfElements(prhs[0]);
        const mwSize *psz;
        
        std::string plane_name;
        
        mxArray *field_name_tmp, *mx_bounds, *mx_params;
        Plane p;
        
        for( int i=0; i<NStructElems; i++ )
        {
            field_name_tmp = mxGetField( prhs[0], i, "ID" );
            if( !mxIsChar(field_name_tmp) ) {
                mexErrMsgIdAndTxt( "MATLAB:test_struct:notText",
                        "ID field is apparently not text!");
            }
            
            plane_name = get_mex_string( field_name_tmp );

            mx_bounds = (mxArray*) mxGetField(prhs[0], i, "world");
            mx_params = (mxArray*) mxGetCell(prhs[1],i);
            psz = mxGetDimensions( mx_bounds );
            mexPrintf("ID fo thing: %d\n",i);
            p = Plane( (double*)mxGetPr(mx_bounds), psz, (double*)mxGetPr(mx_params), i, plane_name);
            p.print( );
        }
}