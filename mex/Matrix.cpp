#include "Matrix.hpp"
#include <limits>


Matrix::Matrix( ) {}

Matrix::Matrix( int numRows, int numCols ) {
    this->rows = numRows;
    this->cols = numCols;
    for( int i=0; i<numRows; i++ ) {
        std::map<int, double> row;
        this->elems[i] = row;
    }
}

void Matrix::set( int i, int j, double val ) {
    if(i<0 || j<0 || i >= rows || j >= cols) {
         mexPrintf("i: %d, j: %d -> (%d x %d)\n", i, j, this->rows, this->cols);
         mexEvalString("drawnow");
         throw std::out_of_range ("i or j was out of range.");
    }
    this->elems[i][j] = val;
}

double Matrix::at( int i, int j ) const {
    return this->elems.find(i)->second.find(j)->second;
}

void Matrix::toDouble( double *dbl ) const {
    for( int i=0; i < this->rows; i++ ) {
        for( int j=0; j < this->cols; j++ ) {
            dbl[i+j*this->rows] = this->at(i,j);
        }
    }
}

void Matrix::fromDouble( double *dbl ) {
    for( int i=0; i < this->rows; i++ ) {
        for( int j=0; j < this->cols; j++ ) {
          this->set(i,j, dbl[i+j*this->rows]);
        }
    }
}

void Matrix::fromVector( std::vector<float> &vec )
{
    if( vec.size( ) != this->rows && this->cols != 1)
        mexErrMsgTxt("Invalid vector size compared to initialisation values for vector.");
    for( unsigned int i=0; i < vec.size( ); i++ ) 
    {
        this->set(i,0,vec.at(i));
    }
}

void Matrix::print( ) const {
    for( int i=0; i < this->rows; i++ ) {
        mexPrintf( "[ " );
        for( int j=0; j < this->cols; j++ ) {
            mexPrintf( "%10g ", this->at(i,j) );
        }
        mexPrintf( " ]\n" );
    }
        mexPrintf( " \n" );
}

void Matrix::fromArray( double **m ) {

    for( int i=0; i < this->rows; i++ ) {
        for( int j=0; j < this->cols; j++ ) {
            this->set( i, j, m[i][j] );
        }
    }
}

double Matrix::mag( ) {
    if( !this->isVector( ) ) {
        mexErrMsgTxt("Matrix must be 1xn or nx1 for `mag`");
    }
    
    /*double sqsum = 0;
    for( int i=0; i < this->rows; i++ ) {
        for( int j=0; j < this->cols; j++ ) {
            sqsum += pow(this->at(i,j),2);
        }
    }*/
    return sqrt(pow(this,2).sum( ));
}

const Matrix Matrix::operator*( const Matrix& m ) const {
    Matrix out = Matrix(this->rows,m.cols);

    double sum_elems;
    for( int i = 0; i < this->rows; ++i) {
        for(int j = 0; j < m.cols; ++j) {
            sum_elems = 0;
            for( int k = 0; k < m.rows; ++k) {
                sum_elems += this->at(i,k) * m.at(k,j);
            }
            out.set(i,j,sum_elems);
        }
    }
    return out;
}


const Matrix Matrix::operator*( const double& val ) const {
    Matrix out = Matrix(this->rows,this->cols);

    double sum_elems;
    for( int i = 0; i < this->rows; ++i) {
        for(int j = 0; j < this->cols; ++j) {
           out.set( i, j, val*this->at(i,j) );
        }
    }
    return out;
}


const Matrix Matrix::operator/( const double& val ) const {
    Matrix out = Matrix(this->rows,this->cols);
    
    for( int i = 0; i < this->rows; ++i)
        for(int j = 0; j < this->cols; ++j)
           out.set( i, j, this->at(i,j)/val );
    return out;
}


Matrix& Matrix::operator/=( const double& val ) {
    for( int i = 0; i < this->rows; ++i)
        for(int j = 0; j < this->cols; ++j)
           this->set( i, j, this->at(i,j)/val );
    return *this;
}

const Matrix Matrix::operator+( const  Matrix& m ) const {
    
    if(this->cols != m.cols || this->rows != m.rows) {
        std::stringstream errString;
    this->print( );
    m.print( );
        errString << "Matrix sizes do not agree for addition (" << this->rows << " x " << this->cols << "  vs  " << m.rows << " x " << m.cols << ").\n";
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidSize",
                errString.str( ).c_str() );
    }
    Matrix out = Matrix(this->rows,this->cols);

    double sum_elems;
    for( int i = 0; i < this->rows; ++i) {
        for(int j = 0; j < this->cols; ++j) {
           out.set( i, j, this->at(i,j) + m.at(i,j) );
        }
    }
    return out;
}


const Matrix Matrix::operator-( const  Matrix& m ) const {
    
    if(this->cols != m.cols || this->rows != m.rows) {
        std::stringstream errString;
        errString << "Matrix sizes do not agree for subtraction (" << this->rows << " x " << this->cols << "  vs  " << m.rows << " x " << m.cols << ").\n";
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidSize",
                errString.str( ).c_str() );
    }
                //"Matrix sizes do not agree.");
    
    Matrix out = Matrix(this->rows,this->cols);

    double sum_elems;
    for( int i = 0; i < this->rows; ++i) {
        for(int j = 0; j < this->cols; ++j) {
           out.set( i, j, this->at(i,j) - m.at(i,j) );
        }
    }
    return out;
}


Matrix Matrix::transpose( ) {
    Matrix m = Matrix( this->cols, this->rows );
    for(int r = 0; r < this->rows; r++ ) {
        for( int c = 0; c < this->cols; c++ ) {
            m.set(r,c, this->at(c,r));
        }
    }
    return m;
}

double Matrix::sum( ) const {
    double sum = 0;
    for( int i=0; i < this->rows; i++ )
        for( int j=0; j < this->cols; j++ )
            sum += this->at(i,j);
    
    return sum;
}


Matrix Matrix::elemMult( Matrix *val ) {
    Matrix out = Matrix(this->rows,this->cols);

    double sum_elems;
    for( int i = 0; i < this->rows; ++i) {
        for(int j = 0; j < this->cols; ++j) {
           out.set( i, j, val->at(i,j)*this->at(i,j) );
        }
    }
    return out;
}


double Matrix::min( bool ignoreDiag, int *minIout, int *minJout )
{
    double minVal = std::numeric_limits<float>::max( );
    int minI = -1,
        minJ = -1;
    
    for( int i = 0; i < this->rows; ++i) {
        for(int j = 0; j < this->cols; ++j) {
            if(ignoreDiag && i==j) 
                continue;
            if( int tmp = this->at(i,j) < minVal ) {
                minVal = tmp;
                minI = i;
                minJ = j;
            }
        }
    }
    
    *minIout = minI;
    *minJout = minJ;
    
    return minVal;
}

double Matrix::max( bool ignoreDiag, int *maxIout, int *maxJout )
{
    double maxVal = std::numeric_limits<float>::min( );
    int maxI = -1,
        maxJ = -1;
    
    for( int i = 0; i < this->rows; ++i) {
        for(int j = 0; j < this->cols; ++j) {
            if(ignoreDiag && i==j) 
                continue;
            int tmp = this->at(i,j);
            if( tmp > maxVal ) {
                maxVal = tmp;
                maxI = i;
                maxJ = j;
            }
        }
    }
    
    *maxIout = maxI;
    *maxJout = maxJ;
    
    return maxVal;
}

/** Outside Functions (static/friend) **/

Matrix pow( Matrix *m, double exp ) {
    Matrix out = Matrix( m->rows, m->cols );
    for( int i=0; i < m->rows; i++ )
        for( int j=0; j < m->cols; j++ )
            out.set(i,j,pow(m->at(i,j),exp));
    return out;
}

Matrix Matrix::eye( int sz ) 
{
    Matrix I(sz,sz);
    for( int i=0; i < sz; i++ ) {
        for( int j=0; j < sz; j++ ) {
            if( i==j )
                I.set(i,j,1);
            else
                I.set(i,j,0);
        }
    }
    
    return I;
    
}
    

Matrix Matrix::cross( const Matrix &M, const Matrix &N ) {
    if( M.rows != N.rows && M.cols != N.cols )
    {
        mexErrMsgTxt("Matrices must be the same size (Matrix::cross)");
    }
    
    if( M.rows != 3 && M.cols != 1 )
    {
        mexErrMsgTxt("Matrix must represent a 3x1 vector. (Matrix::cross");
    }
    
    Matrix crs(3,1);
    crs.set(0,0, M.at(1,0)*N.at(2,0) - M.at(2,0)*N.at(1,0));
    crs.set(1,0, M.at(2,0)*N.at(0,0) - M.at(0,0)*N.at(2,0));
    crs.set(2,0, M.at(0,0)*N.at(1,0) - M.at(1,0)*N.at(0,0));
    return crs;
}

Matrix Matrix::inv33( ) const
{
    // computes the inverse of a matrix m
    double det = this->at(0,0) * (this->at(1,1) * this->at(2,2) - this->at(2,1) * this->at(1,2)) -
                this->at(0,1) * (this->at(1,0) * this->at(2,2) - this->at(1,2) * this->at(2,0)) +
                this->at(0,2) * (this->at(1,0) * this->at(2,1) - this->at(1,1) * this->at(2,0));

    double invdet = 1 / det;

    Matrix minv(3,3); // inverse of matrix m
    minv.set(0,0,(this->at(1,1) * this->at(2,2) - this->at(2,1) * this->at(1,2)) * invdet);
    minv.set(0,1,(this->at(0,2) * this->at(2,1) - this->at(0,1) * this->at(2,2)) * invdet);
    minv.set(0,2,(this->at(0,1) * this->at(1,2) - this->at(0,2) * this->at(1,1)) * invdet);
    minv.set(1,0,(this->at(1,2) * this->at(2,0) - this->at(1,0) * this->at(2,2)) * invdet);
    minv.set(1,1,(this->at(0,0) * this->at(2,2) - this->at(0,2) * this->at(2,0)) * invdet);
    minv.set(1,2,(this->at(1,0) * this->at(0,2) - this->at(0,0) * this->at(1,2)) * invdet);
    minv.set(2,0,(this->at(1,0) * this->at(2,1) - this->at(2,0) * this->at(1,1)) * invdet);
    minv.set(2,1,(this->at(2,0) * this->at(0,1) - this->at(0,0) * this->at(2,1)) * invdet);
    minv.set(2,2,(this->at(0,0) * this->at(1,1) - this->at(1,0) * this->at(0,1)) * invdet);

    return minv;
}