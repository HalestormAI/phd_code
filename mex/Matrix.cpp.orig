#include "Matrix.hpp"

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
    if(i<0 || j<0 || i >= rows || j >= cols)
         throw std::out_of_range ("i or j was out of range.");
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

void Matrix::print( ) const {
    for( int i=0; i < this->rows; i++ ) {
        mexPrintf( "[ " );
        for( int j=0; j < this->cols; j++ ) {
            mexPrintf( "%g ", this->at(i,j) );
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


/** Outside Functions **/

Matrix pow( Matrix *m, double exp ) {
    Matrix out = Matrix( m->rows, m->cols );
    for( int i=0; i < m->rows; i++ )
        for( int j=0; j < m->cols; j++ )
            out.set(i,j,pow(m->at(i,j),exp));
    return out;
}