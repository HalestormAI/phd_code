#ifndef _IJH_FUNCTIONS_
#define _IJH_FUNCTIONS_ 1

#include <math.h>
#include <cstdlib>
#include "Matrix.hpp"
#include "Point.hpp"
#include "Plane.hpp"
#include "mex.h"

#ifndef PI
#define PI 3.1415926535897932384626433832795028841971693993751058209749
#endif
#define DEG2RAD(DEG) ((DEG)*((PI)/(180.0)))

Matrix xRotate( float theta );
Matrix yRotate( float theta );
Matrix zRotate( float theta );


float myrand( float mult );
double vec_mag( double *vec, int sz );
#endif