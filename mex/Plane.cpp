#include "Plane.hpp"

Plane::Plane( double *boundDbl, const mwSize *boundaryDims, double *paramsDbl, int id ) {
    this->n.push_back(paramsDbl[0]);
    this->n.push_back(paramsDbl[1]);
    this->n.push_back(paramsDbl[2]);
    this->d = paramsDbl[3];
    
    this->boundariesFromDouble( boundDbl, boundaryDims );
    
    this->minmaxBounds( );
    
    this->id = id;
}

void Plane::boundariesFromDouble( double *boundaries , const mwSize *dims ) {
    
    float x,y,z;
    
    for(int col=0;col < dims[1]; col++) {
        x = boundaries[0+col*dims[0]];
        y = boundaries[1+col*dims[0]];
        z = boundaries[2+col*dims[0]];
        this->boundaries.push_back( Point( x, y, z ) );
    }
}

void Plane::minmaxBounds( ) {
    
    float maxFloat = std::numeric_limits<float>::max();
    this->minboundaries = Point( maxFloat,maxFloat,maxFloat );
    this->maxboundaries = Point( -maxFloat,-maxFloat,-maxFloat );
    
    std::vector<Point>::iterator i;
    for( i = this->boundaries.begin( ); i != this->boundaries.end( ); i++)
    {
        this->minboundaries.X = (i->X < this->minboundaries.X) ? i->X : this->minboundaries.X;
        this->minboundaries.Y = (i->Y < this->minboundaries.Y) ? i->Y : this->minboundaries.Y;
        this->minboundaries.Z = (i->Z < this->minboundaries.Z) ? i->Z : this->minboundaries.Z;
        
        this->maxboundaries.X = (i->X > this->maxboundaries.X) ? i->X : this->maxboundaries.X;
        this->maxboundaries.Y = (i->Y > this->maxboundaries.Y) ? i->Y : this->maxboundaries.Y;
        this->maxboundaries.Z = (i->Z > this->maxboundaries.Z) ? i->Z : this->maxboundaries.Z;
    }
}

void Plane::print( ) {
    std::stringstream ss;
    ss << "Parameters: \n\t n = (" << this->n[0] << "," << this->n[1]
       << "," << this->n[2] << ")\n\t " << this->d << "\n\nBoundaries: \n";
    
    std::vector<Point>::iterator i;
    for( i = this->boundaries.begin( ); i != this->boundaries.end( ); i++ ) {
        ss << "\t" << i->toStr3D( );
    }
    
    ss << "\nMinmax:\n\t" << this->minboundaries.toStr3D( ) << "\t"
       << this->maxboundaries.toStr3D( ) << std::endl;
        
    mexPrintf( ss.str( ).c_str( ) );
    mexEvalString("drawnow");
}

bool Plane::checkBounds( Point *p, bool notZ ) {
    float leeway = 0.01;
    bool xin = this->minboundaries.X-leeway <= p->X && p->X <= this->maxboundaries.X+leeway;
    bool yin = this->minboundaries.Y-leeway <= p->Y && p->Y <= this->maxboundaries.Y+leeway;
    bool zin = this->minboundaries.Z-leeway <= p->Z && p->Z <= this->maxboundaries.Z+leeway;
    
    bool zwin = notZ ? true : zin;
    
    return xin && yin && zwin;
}

Plane* Plane::findPlane( std::vector<Plane> *planes, Point *pos, bool debug ) {
    Plane *curPlane = 0;
    
    std::vector<Plane>::iterator iter;
    for( iter = planes->begin( ); iter != planes->end( ); iter++ ) {
        
        if( iter->checkBounds( pos, true ) ) {
            curPlane = &(*iter);
            break;
        }
    }

    return curPlane;
}

std::vector<Point> Plane::intersection( Plane *oldPlane, Plane *newPlane ) {
    std::vector<Point>::iterator it1, it2;
    
    std::vector<Point> intersect;
    for( it1 = oldPlane->boundaries.begin( ); it1 != oldPlane->boundaries.end( ) ; it1++ ) {
        for( it2 = newPlane->boundaries.begin( ); it2 != newPlane->boundaries.end( ) ; it2++ ) {
            if(*it1 == *it2)
                intersect.push_back(*it1);
        }
    }
    return intersect;
}

void Plane::anglesFromN( std::vector<float> n, float *theta, float *psi ) {
    *theta = PI - acos( n[2] );
    *psi   = asin( -n[0] / sin(*theta) );
    if( isnan( *psi ) )
        *psi = 0;
}