#include "Plane.hpp"
#include <algorithm>

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
        this->minboundaries.setX( (i->getX( ) < this->minboundaries.getX( )) ? i->getX( ) : this->minboundaries.getX( ) );
        this->minboundaries.setY( (i->getY( ) < this->minboundaries.getY( )) ? i->getY( ) : this->minboundaries.getY( ) );
        this->minboundaries.setZ( (i->getZ( ) < this->minboundaries.getZ( )) ? i->getZ( ) : this->minboundaries.getZ( ) );
        
        this->maxboundaries.setX( (i->getX( ) > this->maxboundaries.getX( )) ? i->getX( ) : this->maxboundaries.getX( ) );
        this->maxboundaries.setY( (i->getY( ) > this->maxboundaries.getY( )) ? i->getY( ) : this->maxboundaries.getY( ) );
        this->maxboundaries.setZ( (i->getZ( ) > this->maxboundaries.getZ( )) ? i->getZ( ) : this->maxboundaries.getZ( ) );
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

bool Plane::checkBounds( Point p, bool notZ, bool debug ) {
    float leeway = 0;
    bool xin = this->minboundaries.getX( )-leeway <= p.getX( ) && p.getX( ) <= this->maxboundaries.getX( )+leeway;
    bool yin = this->minboundaries.getY( )-leeway <= p.getY( ) && p.getY( ) <= this->maxboundaries.getY( )+leeway;
    bool zin = this->minboundaries.getZ( )-leeway <= p.getZ( ) && p.getZ( ) <= this->maxboundaries.getZ( )+leeway;
    
    bool zwin = notZ ? true : zin;
    bool result = xin && yin && zwin;
    
//     if( debug && !result ) {
//         mexPrintf("Point not on plane: \n\tMinpt: ");
//         this->minboundaries.print3D( );
//         mexPrintf("\tMaxpt: ");
//         this->maxboundaries.print3D( );
//         mexPrintf("\tPoint: ");
//         p.print3D( );
//         mexPrintf("\n=================\n");
//     }
    return result;
}

Plane* Plane::findPlane( std::vector<Plane> *planes, Point pos, bool debug ) {
    Plane *curPlane = 0;
    
    std::vector<Plane>::iterator iter;
    for( iter = planes->begin( ); iter != planes->end( ); iter++ ) {
        
        if( iter->checkBounds( pos, true ) ) {
            curPlane = &(*iter);
            if(debug) {
               // mexPrintf("(findplane) Found at: %d\n", iter-planes->begin( ));mexEvalString("drawnow");
            }
            break;
        }
    }
    return curPlane;
}

std::vector<Point> Plane::intersection( Plane *oldPlane, Plane *newPlane ) {
    std::vector<Point> intersection_points;

    // First, get plane intersection ( n1 x n2 ) / norm( n1 x n2 )
    Point npdiffpt, opdiffpt;
    double n[3], npdiff[3], opdiff[3];
    newPlane->intersect(*oldPlane,n);
    //mexPrintf("N: [ %g\n     %g\n     %g]\n\n", n[0],n[1],n[2]);
    
    double mag = vec_mag(n,3);
    //mexPrintf("N: [ %g\n     %g\n     %g]\n(mag: %g)\n", n[0],n[1],n[2], mag);
    
    n[0] /= mag;
    n[1] /= mag;
    n[2] /= mag;
    
    std::vector<Point> possible_intersects;
    std::vector<Line> newPlaneLines, oldPlaneLines;
    
    double eps = std::numeric_limits<double>::epsilon()*100;
    mexPrintf("Eps: %g\n", eps);
    
    for( unsigned int p1 = 0; p1 < oldPlane->boundaries.size( ); p1++ ) {
        unsigned int p2 = p1 + 1;
        if( p2 >= oldPlane->boundaries.size( ) ) {
            p2 = 0;
        }
        
        // This is horrible code...
        opdiffpt = (oldPlane->boundaries[p1] - oldPlane->boundaries[p2]);
        npdiffpt = (newPlane->boundaries[p1] - newPlane->boundaries[p2]);
        
        // Convert to double so we can use vec_mag
        opdiffpt.toDouble(opdiff);
        npdiffpt.toDouble(npdiff);
        
        // Use mag on point
        opdiffpt = opdiffpt / vec_mag(opdiff,3);
        npdiffpt = npdiffpt / vec_mag(npdiff,3);
        
        // Check direction of lines is the same as plane-plane intersection line
        if( fabs(fabs(n[0]) - fabs(opdiffpt.getX( ))) < eps && 
            fabs(fabs(n[1]) - fabs(opdiffpt.getY( ))) < eps && 
            fabs(fabs(n[2]) - fabs(opdiffpt.getZ( ))) < eps) {
            
            oldPlaneLines.push_back(Line(oldPlane->boundaries[p1],oldPlane->boundaries[p2]));
        }
        
        if( fabs(fabs(n[0]) - fabs(npdiffpt.getX( ))) < eps && 
            fabs(fabs(n[1]) - fabs(npdiffpt.getY( ))) < eps && 
            fabs(fabs(n[2]) - fabs(npdiffpt.getZ( ))) < eps) {
            newPlaneLines.push_back(Line(newPlane->boundaries[p1],newPlane->boundaries[p2]));
        }
    }
    

    // For each line, take a point and find out if we have any lines which pass through the same point
    // This gets rid of lines parallel to but not ON the line of intersection
    for(unsigned int l=0; l < oldPlaneLines.size( ); l++ ) 
    {
        for( unsigned int l2=0; l2 < newPlaneLines.size( ); l2++ )
        {
            Line l11 = oldPlaneLines.at(l),
                 l12 = newPlaneLines.at(l2);
            
            double drn11[3];
            l11.getDrn(drn11);
            
            if( Line::checkPointOnLine( l11.start, drn11, l12.start ) ) {
                possible_intersects.push_back(l11.start);
                possible_intersects.push_back(l11.end);
                possible_intersects.push_back(l12.start);
                possible_intersects.push_back(l12.end);
            }
        }
    }

    if( possible_intersects.size() != 4 )
    {
        mexErrMsgTxt("Didn't get 4 intersect points...");
    }
    
    // Get distances between each pair of points
    Matrix distances(4,4);
    for( unsigned int i=0; i < 4; i++ )
    {
        for( unsigned int j=0; j < 4; j++ )
        {
            distances.set(i,j,possible_intersects[i].dist(possible_intersects[j]));
        }
    }
    
    
    // We want the middle two, so find the ones with max. distance between then and discard
    int maxRow, maxCol;
    distances.max( true, &maxRow, &maxCol );
    
    int skippedRows = 0, 
        skippedCols = 0;
    
    
    // Work out row/col mapping
    int init_mapping_raw[4] = {0,1,2,3};
    std::vector<int> init_mapping;
    init_mapping.assign(init_mapping_raw, init_mapping_raw+4);
    std::remove(init_mapping.begin( ), init_mapping.end( ), maxRow);
    std::remove(init_mapping.begin( ), init_mapping.end( ), maxCol);
    
   
    
    // What remains are our intersection points.
    intersection_points.push_back( possible_intersects.at(init_mapping[0]) );
    intersection_points.push_back( possible_intersects.at(init_mapping[1]) );
    
        
        
    // Now get pairs of points which match this drn (p1 - p2)
    /*std::vector<Point> intersect;
    for( it1 = oldPlane->boundaries.begin( ); it1 != oldPlane->boundaries.end( ) ; it1++ ) {
        for( it2 = newPlane->boundaries.begin( ); it2 != newPlane->boundaries.end( ) ; it2++ ) {
            
            
            // For each pair, get the cross product of the 2 points
            
            // do check on line
            
            
        }
    }*/
    if(intersection_points.size( ) < 2) {
        mexErrMsgTxt("Not enough intersects");
    }
    return intersection_points;
}

void Plane::anglesFromN( std::vector<float> n, float *theta, float *psi ) {
    *theta = PI - acos( n[2] );
    *psi   = asin( -n[0] / sin(*theta) );
    if( isnan( *psi ) )
        *psi = 0;
}

void Plane::intersect( Plane &b, double (&n)[3] )
{
    n[0] = this->n[1]*b.n[2] - b.n[1]*this->n[2];
    n[1] = this->n[2]*b.n[0] - b.n[2]*this->n[0];
    n[2] = this->n[0]*b.n[1] - b.n[0]*this->n[1];
//     mexPrintf("N_a: [ %g\n     %g\n     %g]\n", this->n[0],this->n[1],this->n[2]);
//     mexPrintf("N_b: [ %g\n     %g\n     %g]\n", b.n[0],b.n[1],b.n[2]);
//     mexPrintf("I: [ %g\n     %g\n     %g]\n-------------------\n", n[0],n[1],n[2]);
}


Matrix Plane::getDrn( bool switcharoo ) 
{
    // Find (minx,miny) -> (maxx,miny) direction vector
    
    int miny = std::numeric_limits<int>::max( ),
        minx = std::numeric_limits<int>::max( ),
        maxx = std::numeric_limits<int>::min( );
    
    Point st,nd;
    
    for( unsigned int i=0;i < this->boundaries.size( ); i++ )
    {
        if( this->boundaries[i].getY( ) <= miny && this->boundaries[i].getX( ) < minx )  {
            st = this->boundaries[i];
            miny = st.getY( );
            minx = st.getX( );
        }
        if( this->boundaries[i].getY( ) <= miny && this->boundaries[i].getX( ) > maxx )  {
            nd = this->boundaries[i];
            miny = nd.getY( );
            maxx = nd.getX( );
        }
    }

    return (switcharoo ? (st-nd) : (nd-st)).toMatrix( );
    
}