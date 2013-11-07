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

void Point::print( ) const
{
    if(this->is3D)
        this->print3D( );
    else
        this->print2D( );
}

std::string Point::toStr( ) const
{
    if(this->is3D)
        return this->toStr3D( );
    else
        return this->toStr2D( );
    
}

void Point::print2D( ) const
{
    mexPrintf( this->toStr2D( ).c_str( ) );
    mexEvalString("drawnow");
}

std::string Point::toStr2D( ) const
{
    std::stringstream ss;
    ss << std::right << std::fixed << std::setw(12) << this->x << std::right << std::fixed << std::setw(12) << this->y << std::endl;
    return ss.str( );
    
}

void Point::print3D( ) const
{
    mexPrintf( this->toStr3D( ).c_str( ) );
    mexEvalString("drawnow");
}

std::string Point::toStr3D( ) const
{
    
    std::stringstream ss;
    
    ss << std::right << std::fixed << std::setw(12) << this->X << std::right << std::fixed << std::setw(12) <<  this->Y << std::right << std::fixed << std::setw(12)  << this->Z << std::endl;
    return ss.str( );
}
    

double Point::dist( const Point pt ) const {
    float dist;
    if(this->is2D) {
        float dx = (this->x - pt.x);
        float dy = (this->y - pt.y);

        dist = sqrt(pow(dx,2) + pow(dy,2));
    } else {
        float dx = (this->X - pt.X);
        float dy = (this->Y - pt.Y);
        float dz = (this->Z - pt.Z);

        dist = sqrt(pow(dx,2) + pow(dy,2) + pow(dz,2));
    }
        
    return dist;
}
double Point::dist2D( const Point pt ) const {
    return this->dist(pt);
}

void Point::calibTsai( Etiseo::CameraModel *cam ) {
   float Z = 1;
   this->Z = Z;

   cam->imageToWorld(this->x, this->y, this->Z, this->X, this->Y);
   this->is3D = true;
}

Point Point::move( Matrix *drn, float spd ) const {
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
    if( p1.is2D )
        return Point( p1.x + p2.x, p1.y + p2.y );
    else
        return Point( p1.X + p2.X, p1.Y + p2.Y, p1.Z + p2.Z );
}
Point operator- (const Point &p1, const Point &p2) {
    if( p1.is2D )
        return Point( p1.x - p2.x, p1.y - p2.y );
    else
        return Point( p1.X - p2.X, p1.Y - p2.Y, p1.Z - p2.Z );
}

Point operator/ (const Point &p1, const double val) {
    if( p1.is2D )
        return Point( p1.x / val, p1.y / val );
    else
        return Point( p1.X / val, p1.Y / val, p1.Z / val );
}

Point operator* (const double val, const Point &p1) {
    if( p1.is2D )
        return Point( val*p1.x, val*p1.y );
    else
        return Point( val*p1.X, val*p1.Y, val*p1.Z );
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

Matrix Point::toMatrix( ) const {
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

Point Point::fromString( std::string str )
{
    double x,y,z;
    Point P;
    
    std::istringstream cast_buffer;
    std::vector<std::string> tokens;
    std::istringstream iss(str);
    
    // Copy each element of the line into the string vector
    copy(std::istream_iterator<std::string>(iss),
         std::istream_iterator<std::string>(),
         std::back_inserter<std::vector<std::string> >(tokens));
    
    
    // Now use the size of the buffer to decide 2d or 3d
    bool is3d = tokens.size( ) > 2;

    // Need to cast x and y for both
    cast_buffer.str(tokens.at(0));
    cast_buffer >> x;
    cast_buffer.clear( );
    cast_buffer.str(tokens.at(1));
    cast_buffer >> y;
    cast_buffer.clear( );
    
    
    // If 3d, cast z and create point
    if( is3d ) {
        cast_buffer.str(tokens.at(2));
        cast_buffer >> z;
        P = Point( x, y, z );
    } else {
        P = Point( x, y );
    }
    
    return P;

}


void Point::toDouble( double *out ) {
    if(this->is2D) {
        out[0] = this->x;
        out[1] = this->y;
    } else {
        out[0] = this->X;
        out[1] = this->Y;
        out[2] = this->Z;
    }
}