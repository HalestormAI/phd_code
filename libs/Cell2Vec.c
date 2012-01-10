// Cell2Vec.c   [Works well, but I do not need it ever]
// CELL2VEC - Concatenate cell elements to a vector
// The elements of arrays, which are elements of the input cell, are
// concatenated to a vector.
// If the cell elements are vectors, this equals CAT, but is remarkably
// faster for large cells: It seems that CAT does not use pre-allocation?!
// E.g. for a {1 x 5000} cell string with a total of 200.000 CHARs:
//   CAT (Matlab 6.5) => 60 sec
//   CAT (Matlab 7.8) => 5 sec
//   Cell2Vec:        => 1.2 sec   (1.5GHz Pentium-M).
//
// V = Cell2Vec(C)
// INPUT:
//   C: Cell array of any size. Accepted classes: all numerical types
//      (DOUBLE, SINGLE, (U)INT8/16/32/64), LOGICAL, CHAR.
//      All non-empty cell elements must be the same class.
// OUTPUT:
//   V: [1 x N] vector of all elements. The class of V is the class of the
//      cell elements of C.
//
// COMPILATION:
//   (mex -setup   % if not done before)
//   mex -O Cell2Vec.c
// Linux: consider C99 comments:
//   mex -O CFLAGS="\$CFLAGS -std=C99" Cell2Vec.c
// Download: http://www.n-simon.de/mex
// Run the unit-test uTest_Cell2Vec after compiling.
//
// Tested: Matlab 6.5, 7.7, 7.8, WinXP, 32bit
//         Compiler: LCC2.4/3.8, BCC5.5, OWC1.8, MSVC2008
// Assumed Compatibility: higher Matlab versions, Mac, Linux, 64bit
// Author: Jan Simon, Heidelberg, (C) 2010 matlab.THISYEAR(a)nMINUSsimon.de
//
// See also CELL2MAT, CStr2String.

/*
% $JRev: R0p V:003 Sum:/GyPG13N4zv2 Date:21-Sep-2010 13:43:49 $
% $License: BSD (see Docs\BSD_License.txt) $
% $UnitTest: uTest_Cell2Vec $
% $File: Tools\Mex\Source\Cell2Vec.c $
% History:
*/

#include "mex.h"
#include <string.h>

// Assume 32 bit array dimensions for Matlab 6.5:
// See MEX option "compatibleArrayDims" for MEX in Matlab >= 7.7.
#ifndef MWSIZE_MAX
#define mwSize  int32_T           // Defined in tmwtypes.h
#define mwIndex int32_T
#define MWSIZE_MAX MAX_int32_T
#endif

// Error messages do not contain the function name in Matlab 6.5! This is not
// necessary in Matlab 7, but it does not bother:
#define ERR_HEAD "Cell2Vec: "
#define ERR_ID   "JSimon:Cell2Vec:"

// Main function ===============================================================
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  const mxArray *C, *aC;
  mwSize SumLen = 0, Len, nC, Dims[2], ElementSize;
  mwIndex iC;
  char *P;
  mxClassID ClassID = mxUNKNOWN_CLASS;
  bool anyNULL = false;
   
  // Check proper number of arguments:
  if (nrhs != 1) {
     mexErrMsgIdAndTxt(ERR_ID   "BadNInput",
                       ERR_HEAD "1 input required.");
  }
  if (nlhs > 1) {
     mexErrMsgIdAndTxt(ERR_ID   "BadNOutput",
                       ERR_HEAD "1 output allowed.");
  }
   
  // Create a pointer to the input cell and check the type:
  C = prhs[0];
  if (!mxIsCell(C)) {
     mexErrMsgIdAndTxt(ERR_ID   "BadtypeInput1",
                       ERR_HEAD "Input must be a cell.");
  }
   
  // Get number of dimensions of the input string and cell:
  nC = mxGetNumberOfElements(C);
  if (nC == 0) {
     plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
     return;
  }
   
  // Get type of first cell element:
  aC = mxGetCell(C, 0);
  if (aC != NULL) {
     ClassID     = mxGetClassID(aC);
     ElementSize = mxGetElementSize(aC);
     if (!(mxIsNumeric(aC) || mxIsChar(aC)) || mxIsComplex(aC)) {
        mexErrMsgIdAndTxt(ERR_ID   "BadCellElement",
                          ERR_HEAD
                          "Cell elements must be numeric or char arrays.");
     }
     
  } else {  // Cell element is NULL pointer - treat it as empty double matrix:
     ClassID     = mxDOUBLE_CLASS;
     ElementSize = sizeof(double);
  }
   
  // Get sum of lenghts and check type of cell elements:
  for (iC = 0; iC < nC; iC++) {
     aC = mxGetCell(C, iC);
     if (aC != NULL) {
        Len = mxGetNumberOfElements(aC);
        if (Len != 0) {
           if (mxGetClassID(aC) != ClassID) {
              mexErrMsgIdAndTxt(ERR_ID   "BadCellElement",
                                ERR_HEAD "Cell elements have different types.");
           }
           SumLen += Len;
        }
        
     } else {  // NULL element:
        // NULL is treated as empty double matrix as usual in Matlab. Such
        // NULLs appears after "cell(1,1)", if the elements are not populated
        // afterwards.
        anyNULL = true;
     }
  }
   
  // Create output vector:
  if (ClassID == mxCHAR_CLASS) {
     Dims[0] = 1;
     Dims[1] = SumLen;
     plhs[0] = mxCreateCharArray(2, Dims);
 } else {
    plhs[0] = mxCreateNumericMatrix(1, SumLen, ClassID, mxREAL);
  }
  P = (char *) mxGetData(plhs[0]);
  
  // Copy array elements into the vector:
  if (anyNULL) {
     for (iC = 0; iC < nC; iC++) {
        aC = mxGetCell(C, iC);
        if (aC != NULL) {
           Len = mxGetNumberOfElements(aC) * ElementSize;
           memcpy(P, mxGetData(aC), Len);
           P  += Len;
        }
     }
     
  } else {  // No NULL elements - omit time consuming test:
     for (iC = 0; iC < nC; iC++) {
        aC  = mxGetCell(C, iC);
        Len = mxGetNumberOfElements(aC) * ElementSize;
        memcpy(P, mxGetData(aC), Len);
        P  += Len;
     }
  }
  
  return;
}
