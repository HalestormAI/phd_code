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

float myrand( float mult ) {
    float r = (float)std::rand( ) / (float)RAND_MAX;
    return r*mult;
}

double vec_mag( double *vec, int sz )
{
    double sum = 0;
    for(int i = 0; i < sz; i++ )
    {
        sum += pow(vec[i],2);
    }
    return sqrt(sum);
}


/**
 * Build a rotation matrix for rotations about the line through (a, b, c)
 * parallel to &lt u, v, w &gt by the angle theta.
 *
 * @param a x-coordinate of a point on the line of rotation.
 * @param b y-coordinate of a point on the line of rotation.
 * @param c z-coordinate of a point on the line of rotation.
 * @param u x-coordinate of the line's direction vector.
 * @param v y-coordinate of the line's direction vector.
 * @param w z-coordinate of the line's direction vector.
 * @param theta The angle of rotation, in radians.
 */
Matrix RotationMatrixFull(double a,
        double b,
        double c,
        double u,
        double v,
        double w,
        double theta) {
    
    
    double l = sqrt(u*u + v*v + w*w);
    
    double m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34,
           u2, v2, w2, l2,
           cosT,
           oneMinusCosT,
           sinT;
    
    
    // Set some intermediate values.
    u2 = u*u;
    v2 = v*v;
    w2 = w*w;
    cosT = cos(theta);
    oneMinusCosT = 1 - cosT;
    sinT = sin(theta);
    l2 = u2 + v2 + w2;
    
    // Build the matrix entries element by element.
    m11 = (u2 + (v2 + w2) * cosT)/l2;
    m12 = (u*v * oneMinusCosT - w*l*sinT)/l2;
    m13 = (u*w * oneMinusCosT + v*l*sinT)/l2;
    m14 = ((a*(v2 + w2) - u*(b*v + c*w)) * oneMinusCosT
            + (b*w - c*v)*l*sinT)/l2;
    
    m21 = (u*v * oneMinusCosT + w*l*sinT)/l2;
    m22 = (v2 + (u2 + w2) * cosT)/l2;
    m23 = (v*w * oneMinusCosT - u*l*sinT)/l2;
    m24 = ((b*(u2 + w2) - v*(a*u + c*w)) * oneMinusCosT
            + (c*u - a*w)*l*sinT)/l2;
    
    m31 = (u*w * oneMinusCosT - v*l*sinT)/l2;
    m32 = (v*w * oneMinusCosT + u*l*sinT)/l2;
    m33 = (w2 + (u2 + v2) * cosT)/l2;
    m34 = ((c*(u2 + v2) - w*(a*u + b*v)) * oneMinusCosT
            + (a*v - b*u)*l*sinT)/l2;
    
    Matrix rot(3,4);
    rot.set(0,0, m11);
    rot.set(0,1, m12);
    rot.set(0,2, m13);
    rot.set(0,3, m14);
    rot.set(1,0, m21);
    rot.set(1,1, m22);
    rot.set(1,2, m23);
    rot.set(1,3, m24);
    rot.set(2,0, m31);
    rot.set(2,1, m32);
    rot.set(2,2, m33);
    rot.set(2,3, m34);
    
    return rot;
    
}