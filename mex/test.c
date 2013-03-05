#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <dlfcn.h>
#include "engine.h"

typedef void (*mexFunction_t)(int nargout, mxArray *pargout [ ], int nargin, const mxArray *pargin[]);

int main(int argc, const char *argv[])

{
  Engine *ep;
  char buff[1024];
  int i;

  /* matlab must be in the PATH! */
  if (!(ep = engOpen("matlab -nodisplay"))) {
    fprintf(stderr, "Can't start MATLAB engine\n");
    return -1;
  }
  engOutputBuffer(ep, buff, 1023);

  /* load the mex file */
  if(argc<2){
    fprintf(stderr, "Error. Give full path to the MEX file as input parameter.\n");
    return -1;
  }
  void *handle = dlopen(argv[1], RTLD_NOW);
  if(!handle){
    fprintf(stderr, "Error loading MEX file: %s\n", strerror(errno));
    return -1;
  }

  /* grab mexFunction handle */
  mexFunction_t mexfunction = (mexFunction_t)dlsym(handle, "mexFunction");
  if(!mexfunction){
    fprintf(stderr, "MEX file does not contain mexFunction\n");
    return -1;
  }

  /* load input data - for convenience do that using MATLAB engine */
  /* NOTE: parameters are MEX-file specific, so one has to modify this*/
  /* to fit particular needs */
  engEvalString(ep, "load testinput.mat");
  mxArray *arg1 = engGetVariable(ep, "Ta");
  mxArray *arg2 = engGetVariable(ep, "Tb");
  mxArray *arg3 = engGetVariable(ep, "weights");
  mxArray *pargout[3] = {0,0,0};
  const mxArray *pargin[3] = {arg1, arg2, arg3};

  /* execute the mex function */
  mexfunction(3, pargout, 3, pargin);

  /* print the results using MATLAB engine */
  engPutVariable(ep, "result", pargout[0]);
  engPutVariable(ep, "result2", pargout[0]);
  engPutVariable(ep, "result3", pargout[0]);
  engEvalString(ep, "result");
  printf("%s\n", buff);
  engEvalString(ep, "result2");
  printf("%s\n", buff);
  engEvalString(ep, "result3");
  printf("%s\n", buff);

  /* cleanup */
  mxDestroyArray(pargout[0]);
  mxDestroyArray(pargout[1]);
  mxDestroyArray(pargout[2]);
  engEvalString(ep, "clear all;");
  dlclose(handle);
  engClose(ep);

  return 0;
}

