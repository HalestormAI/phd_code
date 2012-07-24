#include <math.h>
#include "Point.hpp"

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