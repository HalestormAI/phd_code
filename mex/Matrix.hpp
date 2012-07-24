#ifndef _IJH_MATRIX_
#define _IJH_MATRIX_ 1

#include <map>
#include <stdexcept>
#include <math.h>
#include "mex.h"

class Matrix
{
    public:
        std::map< int, std::map<int, double> > elems;
        int rows;
        int cols;

        Matrix( );
        Matrix( int numRows, int numCols );
        
        void set( int i, int j, double val );
        double at( int i, int j ) const;

        void toDouble( double *dbl ) const;
        void fromDouble( double *dbl );

        void print( ) const;
        
        void fromArray( double **m );
        
        const Matrix operator*( const Matrix& m ) const;
        const Matrix operator*( const double& i ) const;
        const Matrix operator/( const double& i ) const;
        Matrix& operator/=( const double& val );
        const Matrix operator+( const Matrix& m ) const;
        const Matrix operator-( const Matrix& m ) const;
        
        double sum( ) const;
        
        Matrix transpose( );
        
        friend Matrix pow( Matrix *m, double exp );
};

#endif