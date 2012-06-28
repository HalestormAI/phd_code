#include <map>
#include <stdexcept>

class Matrix
{
    public:
        std::map< int, std::map<int, float> > elems;
        int rows;
        int cols;

        Matrix( ) {}

        Matrix( int numRows, int numCols ) {
            this->rows = numRows;
            this->cols = numCols;
            for( int i=0; i<numRows; i++ ) {
                std::map<int, float> row;
                this->elems[i] = row;
            }
        }

        float set( int i, int j, float val ) {
            if(i<0 || j<0 || i >= rows || j >= cols)
                 throw std::out_of_range ("i or j was out of range.");
            this->elems[i][j] = val;
        }

        float at( int i, int j ) {
            return this->elems[i][j];
        }

        void toDouble( double *dbl ) {
            for( int i=0; i < this->rows; i++ ) {
                for( int j=0; j < this->cols; j++ ) {
                    dbl[i+j*this->rows] = this->at(i,j);
                }
            }
        }

        void print( ) {
            for( int i=0; i < this->rows; i++ ) {
                mexPrintf( "[ " );
                for( int j=0; j < this->cols; j++ ) {
                    mexPrintf( "%g ", this->at(i,j) );
                }
                mexPrintf( " ]\n" );
            }
        }

};
