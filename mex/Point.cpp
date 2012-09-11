#include "Point.hpp"


Point::Point( ) {
    this->isN = true;
}

Point::Point( double ix, double iy ) {
   this->x = ix;
   this->y = iy;
   this->isN = false;
   this->is2D = true;
   this->is3D = false;
}
       
Point::Point( double wx, double wy, double wz ) {
   this->X = wx;
   this->Y = wy;
   this->Z = wz;
   this->isN = false;
   this->is2D = false;
   this->is3D = true;
}

Point::Point( Matrix m ) {
    if( m.cols != 1 || m.rows != 3 )
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:invalidSize",
                "Matrix must be 3x1.");
        
    this->X = m.at(0,0);
    this->Y = m.at(1,0);
    this->Z = m.at(2,0);
    this->isN = false;
    this->is3D = true;
    this->is2D = false;
}

void Point::print2D( ) {
    std::stringstream ss;
    ss << std::setw (10) << this->x << "\t" << this->y << std::endl;
    mexPrintf( ss.str( ).c_str( ) );
    mexEvalString("drawnow");
}

void Point::print3D( ) {
    mexPrintf( this->toStr3D( ).c_str( ) );
    mexEvalString("drawnow");
}

std::string Point::toStr3D( ) {
    
    std::stringstream ss;
    ss << this->X << "\t" << this->Y << "\t" << this->Z << std::endl;
    return ss.str( );
}
    

double Point::dist2D( Point pt ) {
    float dx = (this->x - pt.x);
    float dy = (this->y - pt.y);

    float dist = sqrt(pow(dx,2) + pow(dy,2));
    return dist;
}

void Point::calibTsai( Etiseo::CameraModel *cam ) {
   float Z = 1;
   this->Z = Z;

   cam->imageToWorld(this->x, this->y, this->Z, this->X, this->Y);
   this->is3D = true;
}

Point Point::move( Matrix *drn, float spd ) {
    Matrix out;
    out = this->toMatrix( ) + ((*drn)*spd);
    return Point( out );
}

bool operator== (Point &p1, Point &p2) {
    return (p1.X == p2.X) & (p1.Y == p2.Y) && (p1.Z == p2.Z);
}

bool operator!= (Point &p1, Point &p2) {
    return !(p1 == p2);
}

Point operator+ (const Point &p1, const Point &p2) {
    return Point( p1.X + p2.X, p1.Y + p2.Y, p1.Z + p2.Z );
}

Point operator- (const Point &p1, const Point &p2) {
    return Point( p1.X - p2.X, p1.Y - p2.Y, p1.Z - p2.Z );
}

Point Point::cross( Point p ) {
    
    float c1,c2,c3;
    
    c1 = this->Y*p.Z - this->Z*p.Y;
    c2 = this->Z*p.X - this->X*p.Z;
    c3 = this->X*p.Y - this->Y*p.X;
    return Point( c1,c2,c3 );
}

bool Point::isNull( ) {
    return isN;
}

Matrix Point::toMatrix( ) {
    Matrix m;
    if( this->is3D ) {
        m = Matrix(3,1);
        m.set(0,0,this->X);
        m.set(1,0,this->Y);
        m.set(2,0,this->Z);
    } else if ( this->is2D ) {
        m = Matrix(2,1);
        m.set(0,0,this->x);
        m.set(1,0,this->y);
    } else {
        mexErrMsgIdAndTxt( "MATLAB:errorfunc:nullpoint",
                "Point has not been set." );
    }
        
    return m;
}