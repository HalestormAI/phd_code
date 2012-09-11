 #include "SimTrajectory.hpp"


SimTrajectory::SimTrajectory( ) {}
SimTrajectory::SimTrajectory( double *spd, double *drn, const mwSize *num_frames ) {
    this->started = false;
    this->finished = false;
    this->startFrame = -1;
    this->double2vec( spd, num_frames[1], &(this->speeds) );
    this->double2vec( drn, num_frames[1], &(this->directions) );
}

void SimTrajectory::double2vec( double *in, const int length, std::vector<double> *out ) {
    for( int i=0; i < length; i++ ) {
        out->push_back( in[i] );
    }
}

Matrix SimTrajectory::drn2mat( int frameNo, Plane *plane ) {
    
    double drn, prevDrn, newDrn;
    drn = this->directions.at(frameNo);
    
    if( frameNo > 0 ) {
        //prevDrn = std::accumulate(this->directions.begin(),this->directions.end(),0);
        //prevDrn = this->directions.at(frameNo-1);
        
        prevDrn = 0;
        
        std::vector<double>::iterator i;
        for( i = this->directions.begin( ); i != this->directions.begin( )+frameNo; i++ ) {
            prevDrn += *i;
        }
    }else
        prevDrn = 0;
    
    // need to get sum of all directions up to now
    newDrn = prevDrn + drn; // angle in radians
    
//     mexPrintf(" Frame: %d\nPrev: %3.5f, Drn: %3.5f, New: %3.5f\n",frameNo,prevDrn, drn, newDrn);
    
    float theta, psi;
    Plane::anglesFromN( plane->n, &theta, &psi );
    
    
    // Get direction along plane
    Matrix planeDrn = (plane->boundaries.at(3) - plane->boundaries.at(0)).toMatrix( );
    planeDrn /= L2norm( planeDrn );
    
    Matrix yRot = yRotate(theta);
    Matrix zRot = zRotate(newDrn);
    
    Matrix rotDrn = (yRot.transpose( )*zRot*yRot*planeDrn);
    return rotDrn;
}

void SimTrajectory::print3D( ) {
    Trajectory::print3D( );
    
    std::stringstream ss;
    ss << "Speeds: \n\t";
    std::vector<double>::iterator i;
    for( i = this->speeds.begin( ); i != this->speeds.end( ); i++ ) {
        ss << *i << "\t";
    }
    ss << "\n\nDirections: \n\t";
    for( i = this->directions.begin( ); i != this->directions.end( ); i++ ) {
        ss << *i << "\t";
    }
    ss << std::endl;
    mexPrintf(ss.str( ).c_str( ));
    mexEvalString("drawnow");
}

void SimTrajectory::addFrame( std::vector<Plane> *planes, int curFrame ) {
    // get last position
    Point *endPos = &(this->points.back( ));
    
    // get plane for this point
    Plane* curPlane = Plane::findPlane( planes, endPos );
//     curPlane->print( );
    
    if(!curPlane) {
        mexPrintf("Point left all planes\n");
        mexEvalString("drawnow");
        this->finish( curFrame );
        return;
    }
    
    // Get new direction
    Matrix drn = this->drn2mat( curFrame, curPlane );
    Point newPos = endPos->move( &drn, this->speeds.at(curFrame) );
    
    if( !curPlane->checkBounds( &newPos ) )  {
//         newPos.print3D( );
        // point changed plane
//         mexPrintf("Changing plane\n"); mexEvalString("drawnow");
        newPos = this->changePlane( planes, endPos, &newPos, curFrame );
    }
    if(newPos.isNull( ))
        this->finish( curFrame );
    else
        this->addPoint( newPos );
}

Point SimTrajectory::changePlane( std::vector<Plane> *planes, Point *oldPos, Point *newPos, int curFrame ) {
    // Find new plane
    Plane* oldPlane = Plane::findPlane( planes, oldPos );
    Plane* newPlane = Plane::findPlane( planes, newPos, 1 );
        
    if( newPlane == 0 ) {
        Point p = Point( );
        return p;
    }
    
    
    // Intersection of oldPlane and new Plane
    std::vector<Point> intersect = Plane::intersection( oldPlane, newPlane );
    Point x0 = *oldPos;
    Point x1 = intersect.at(0);
    Point x2 = intersect.at(1);
    
    Matrix oldDrn = this->drn2mat(curFrame, oldPlane);
    Matrix newDrn = this->drn2mat(curFrame, newPlane);

    
    double d = L2norm( (x2-x1).cross(x0-x1) ) / L2norm( x2-x1 );
    
    double s = this->speeds.at(curFrame);
    
    Point edgePos = Point( x0.toMatrix( ) + oldDrn*d );
    Point newPos2 = edgePos + (newDrn*(s-d));
    
    return newPos2;
    
}


void SimTrajectory::start( int frameNo, std::vector<Plane> *planes ) {
    this->started = true;
    this->startFrame = frameNo;
    
    // Need to give it an initial position on a plane boundary
    this->newStartingPoint( planes );
}

void SimTrajectory::finish( int frameNo ) {
    this->finished = true;
    this->endFrame = frameNo;
}


bool SimTrajectory::isStarted( ) {
    return this->started;
}

bool SimTrajectory::isFinished( ) {
    return this->finished;
}

double addPi( double val ) { return val+PI; }

void SimTrajectory::newStartingPoint( std::vector<Plane> *planes ) {
    
    double r = myrand(1);
    int plane_id = (int)round(r);
    
    int startEnd = 0;
    
    if( plane_id ) {
        plane_id = planes->size( )-1;
        startEnd = 2;
        std::vector<double>::iterator it;
        
//         mexPrintf("Old Directions: [ ");
//         for( it=this->directions.begin( ); it != this->directions.end( ); it++ ) {
//             mexPrintf("%3.3f\t", *it);
//         }
//         mexPrintf(" ]\n");
        this->directions[0] += PI;
        
//         mexPrintf("New Directions: [ ");
//         for( it=this->directions.begin( ); it != this->directions.end( ); it++ ) {
//             mexPrintf("%3.3f\t", *it);
//         }
//         mexPrintf(" ]\n");
    }
    mexPrintf("R: %3.5f, Plane ID: %d\n",r,plane_id);
    
    std::vector<Point> boundaries = planes->at(plane_id).boundaries;
    float newY = boundaries.at(0).Y + myrand(1)*boundaries.at(2).Y;
    Point start = Point(boundaries.at(startEnd).X, newY, boundaries.at(startEnd).Z);
    this->addPoint( start );
    
}