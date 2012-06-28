#include <math.h>
#include <vector>
#define PI 3.14159265358979323846

class Point
{
public:
       double x, y;
       double X,Y,Z;
       
       Point ( ) {}
       Point( float ix, float iy ) {
           this->x = ix;
           this->y = iy;
       }
       
       void print2D( ) {
            std::cout << this->x << "\t" << this->y << std::endl;
       }
       
       void print3D( ) {
            std::cout << this->X << "\t" << this->Y << "\t" << this->Z << std::endl;
       }
       
       float dist2D( Point pt ) {
            float dx = (this->x - pt.x);
            float dy = (this->y - pt.y);

            float dist = sqrt(pow(dx,2) + pow(dy,2));
            return dist;
       }
       
       void calibTsai( Etiseo::CameraModel *cam ) {
           float Z = 1;
           this->Z = Z;
           
           cam->imageToWorld(this->x, this->y, this->Z, this->X, this->Y);
       }
       
       
};

class Line
{
public:
    Point start;
    Point end;
    float m,c;
    
    Line( Point p1, Point p2 ) {
        this->start = p1;
        this->end = p2;
        
        float dx = p1.x - p2.x;
        float dy = p1.y - p2.y;
        
        this->m = dy/dx;
        
        this->c = p1.y - this->m*p1.x;
    }
    
    float ang( Line l ) {
        return atan( abs( (this->m - l.m) / (1+this->m*l.m) ) );
    }
};

class Trajectory
{
public:
    std::vector<Point> points;
    
    Trajectory( double *traj, const mwSize *dims ) {
        this->fromDouble( traj, dims );
    }
    
    void fromDouble( double* traj, const mwSize *dims ) {
    
        float x,y;
        for(int col=0;col < dims[1]; col++) {
            x = traj[0+col*dims[0]];
            y = traj[1+col*dims[0]];
            points.push_back( Point( x, y ) );
        }
    }
    
    void toDouble2D( double *traj ) {
        for( int col=0; col<this->points.size( ); col++ ) {
            traj[0+col*2] = this->points.at(col).x;
            traj[1+col*2] = this->points.at(col).y;
        }
    }
    
    void toDouble3D( double *traj ) {
        for( int col=0; col<this->points.size( ); col++ ) {
            traj[0+col*3] = this->points.at(col).X;
            traj[1+col*3] = this->points.at(col).Y;
            traj[2+col*3] = this->points.at(col).Z;
        }
    }
    
    void print2D( ) {
        std::vector<Point>::iterator i;
        for( i = this->points.begin( ); i != this->points.end( ); i++ ){
            i->print2D( );
        }
    }
    
    void print3D( ) {
        std::vector<Point>::iterator i;
        for( i = this->points.begin( ); i != this->points.end( ); i++ ){
            i->print3D( );
        }
    }
    
    uint length( ) {
        return this->points.size( );
    }

    Point at( int idx ) {
        return this->points.at(idx);
    }
       
    float angleDiff( int aIdx, Trajectory *t, int bIdx ) {
        
//         mexPrintf("%d %d %d (%d)\n%d %d %d (%d)\n\n", aIdx-1, aIdx, aIdx+1, this->points.size( ), bIdx-1, bIdx, bIdx+1, t->points.size( ));
        
        Point p1a = this->at(aIdx-1);
        Point p2a = this->at( aIdx );
        Point p3a = this->at(aIdx+1);
        
        Point p1b = t->at(bIdx-1);
        Point p2b = t->at( bIdx );
        Point p3b = t->at(bIdx+1);
        
        Line l1a = Line( p1a, p2a );
        Line l2a = Line( p2a, p3a );
        Line l1b = Line( p1b, p2b );
        Line l2b = Line( p2b, p3b );
        
        float ang1 = l1a.ang( l2a );
        float ang2 = l1b.ang( l2b );
        
        return abs( ang1/PI - ang2/PI );
    }
    
    void calibTsai( Etiseo::CameraModel *cam ) {
        std::vector<Point>::iterator i;
        for( i = this->points.begin( ); i != this->points.end( ); i++ ){
            i->calibTsai( cam );
        }
    }
        
};