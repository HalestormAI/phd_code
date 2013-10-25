#ifndef _IJH_MATRIX_
#define _IJH_MATRIX_ 1

#include <map>
#include <vector>
#include <stdexcept>
#include <math.h>
#include <sstream>
#include "mex.h"

struct RowCol
{
    int row;
    int col;
    
    RowCol( int r, int c ):
        row(r), col(c) {}
};

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
        
        void fromVector( std::vector<float> &vec );

        void print( ) const;
        
        void fromArray( double **m );
        
        bool isVector( ) { return (this->rows == 1  || this->cols == 1); }
        
        double mag( );
        
        Matrix inv33( ) const;
        
        const Matrix operator*( const Matrix& m ) const;
        const Matrix operator*( const double& i ) const;
        const Matrix operator/( const double& i ) const;
        Matrix& operator/=( const double& val );
        const Matrix operator+( const Matrix& m ) const;
        const Matrix operator-( const Matrix& m ) const;
        
        double sum( ) const;
        
        Matrix transpose( );
        
        Matrix elemMult( Matrix *val );
        
        double min( bool ignoreDiag=false, int *minIout=0, int *minJout=0 );
        double max( bool ignoreDiag=false, int *maxIout=0, int *maxJout=0 );
        
        friend Matrix pow( Matrix *m, double exp );
        
        static Matrix eye( int sz );
        
        static Matrix cross( const Matrix &M, const Matrix &N);
};

#endif