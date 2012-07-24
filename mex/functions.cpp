#include "functions.hpp"

Matrix xRotate( float theta ) {
    Matrix M = Matrix(3,3);
    double row0[3] = { 1,          0,           0 };
    double row1[3] = { 0, cos(theta), -sin(theta) };
    double row2[3] = { 0, sin(theta),  cos(theta) };
    double* mArr[3] = {row0, row1, row2};
    M.fromArray(mArr);
    return M;
}

Matrix yRotate( float theta ) {
    Matrix M = Matrix(3,3);
    double row0[3] = { cos(theta),           0,  sin(theta) };
    double row1[3] = {          0,           1,           0 };
    double row2[3] = {-sin(theta),           0,  cos(theta) };
    double* mArr[3] = {row0, row1, row2};
    M.fromArray(mArr);
    return M;
}

Matrix zRotate( float theta ) {
    Matrix M = Matrix(3,3);
    double row0[3] = { cos(theta), -sin(theta), 0 };
    double row1[3] = { sin(theta),  cos(theta), 0 };
    double row2[3] = {          0,          0,  1 };
    double* mArr[3] = {row0, row1, row2};
    M.fromArray(mArr);
    return M;
}

float L2norm( Point p ) {
    return sqrt(pow(p.X,2) + pow(p.Y,2) + pow(p.Z,2));
}

float L2norm( Matrix *m ) {
    if(m->cols != 1 && m->rows != 1)
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidSize",
                "L2norm requires a vector (mx1 or 1xn Matrix).");
    
    return sqrt(pow(m,2).sum( ));
}

float myrand( float mult ) {
    float r = (float)std::rand( ) / (float)RAND_MAX;
    return r*mult;
}