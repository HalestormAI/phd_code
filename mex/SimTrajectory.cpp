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
    } else {
        prevDrn = 0;
    }
    
    // need to get sum of all directions up to now
    newDrn = prevDrn + drn; // angle in radians
   
    // For this method, see http://stackoverflow.com/questions/9423621/3d-rotations-of-a-plane
    Matrix nMat(3,1);
    nMat.fromVector(plane->n);
    
    
    
    Matrix planeDrn = plane->getDrn( this->reversal );
    planeDrn /= planeDrn.mag( );
    
//     planeDrn.print( );
    
    Matrix mMat(3,1);
    double mMatArr[3] = {0,0,1};
    mMat.fromDouble(mMatArr);
    
    Matrix axis = Matrix::cross(nMat,mMat);
        
    double xAngle = atan( planeDrn.at(1,0) / planeDrn.at(2,0) );
    if(isnan(xAngle)){
        xAngle = 0;
    }
    Matrix xRot = xRotate( xAngle );
    Matrix axisRotX = xRot*planeDrn;
    
    double yAngle = atan(axisRotX.at(0,0)/axisRotX.at(2,0));
    Matrix yRot = yRotate( (PI/2)-yAngle );
    
    Matrix rMat = yRot*xRot;
    
    
    
//     double c = plane->n[2],
//            t = acos(c),
//            s = sin(t),
//            C = 1-c;
//     
//     double x = axis.at(0,0),
//            y = axis.at(1,0),
//            z = axis.at(2,0);
//     
//     
//     Matrix rMat(3,3); 
//     rMat.set(0,0, x*x*C +c  );  rMat.set(0,1, x*y*C -z*s);  rMat.set(0,2, x*z*C +y*s);
//     rMat.set(1,0, y*x*C +z*s);  rMat.set(1,1, y*y*C +c  );  rMat.set(1,2, y*z*C -x*s);
//     rMat.set(2,0, z*x*C -y*s);  rMat.set(2,1, z*y*C +x*s);  rMat.set(2,2, z*z*C +c  );
// 
//     
    Matrix rMatInv = rMat.inv33( );
    
//     double c_i = cos(-t),
//            s_i = sin(-t),
//            C_i = 1-c_i;
//     
//     Matrix rMatInv2;
//     mexPrintf("RMAT (NEW INVERSE): \n");
//     rMatInv2 = rMat.inv33( );
//     rMatInv2.print( );
//     
//     Matrix rMatInv(3,3); 
//     rMatInv.set(0,0, x*x*C_i +c_i  );
//     rMatInv.set(0,1, x*y*C_i -z*s_i);
//     rMatInv.set(0,2, x*z*C_i +y*s_i);
//      
//     rMatInv.set(1,0, y*x*C_i +z*s_i);
//     rMatInv.set(1,1, y*y*C_i +c_i  );
//     rMatInv.set(1,2, y*z*C_i -x*s_i);
//      
//     rMatInv.set(2,0, z*x*C_i -y*s_i);
//     rMatInv.set(2,1, z*y*C_i +x*s_i);
//     rMatInv.set(2,2, z*z*C_i +c_i  );
//     
//     mexPrintf("RMAT(inv): \n");
//     rMatInv.print( );
    Matrix zRot = zRotate(newDrn);
    
    
//     if( plane->id == 1 )  {
    
//         mexPrintf("SimTrajectory.cpp (line 99): nMat:\n", plane->id);
//         nMat.print( );
//         mexPrintf("mMat:\n", plane->id);
//         mMat.print( );
// 
//         mexPrintf("Plane %d Direction:\n", plane->id);
//         planeDrn.print( );
// 
//         mexPrintf("rMat:\n");
//         rMat.print( );
// 
//         mexPrintf("zRot:\n");
//         zRot.print( );
// 
//         mexPrintf("rMatInv:\n");
//         rMatInv.print( );
//         
//         mexPrintf("\nxAngle: %g, yAngle %g\n\n",xAngle, yAngle);
//     }
    
    /*float theta, psi;
    Plane::anglesFromN( plane->n, &theta, &psi );
    
    // Get direction along plane
    Matrix planeDrn = plane->getDrn( );
    planeDrn /= planeDrn.mag( );

    
    // Need something here to account for non-y-axis rotation
    // Get x-y component to find the z-rotation to put the plane in line with 
    double zAngle = 0;
    if(fabs(plane->n[1]) > std::numeric_limits<double>::epsilon( ))
        zAngle = atan(plane->n[0] / plane->n[1]);
    
    
    Matrix plnZRot = zRotate(zAngle),  
           xRot = xRotate(-theta),
           zRot = zRotate(newDrn),
           xRotInv = xRotate(theta),
           plnZRotInv = zRotate(-zAngle);
    
    
    Matrix initRot = xRot*plnZRot;
    initRot.print( );
    Matrix initRotInv = plnZRotInv*xRotInv;
     
    Matrix rotDrn = initRotInv*(zRot*(initRot*planeDrn));*/
    
    Matrix rotDrn = rMatInv*(zRot*(rMat*planeDrn));
    
    
//     if( plane->id == 1 )  {
//         mexPrintf("rotDrn:\n");
//         rotDrn.print( );
//     }
//     if(isnan(rotDrn.at(0,0))) {
//         mexPrintf("WE GOT A NaN! Theta: %g\n Here's the rotation Matrix: \n", t);
//         rMat.print( );
//         mexPrintf("Here's the inverse:\n");
//         rMatInv.print( );
//         mexPrintf("nMat=\n");
//         nMat.print( );
//         mexPrintf("mMat=\n");
//         mMat.print( );
//         mexPrintf("axis=\n");
//         axis.print( );
//         mexEvalString("drawnow");
//         mexErrMsgTxt("And now I must bid you adieu");
//         
//     }
    
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
    Plane* curPlane = Plane::findPlane( planes, *endPos );
    
    /*if(curPlane->id == 2)
        curPlane->print( );*/
    
    if(!curPlane) {
        mexPrintf("Point left all planes\n");
        mexEvalString("drawnow");
        this->finish( curFrame );
        return;
    }
    
    // Get new direction
    Matrix drn = this->drn2mat( curFrame, curPlane );
    
      /*mexPrintf("Printing Direction\n");
      drn.print( );*/
    
    Point newPos = endPos->move( &drn, this->speeds.at(curFrame) );
    
    if( !curPlane->checkBounds( newPos, true, true ) )  {
        // point changed plane
         //mexPrintf("Changing plane\n Newpos: "); mexEvalString("drawnow");
         //newPos.print3D( );
        
        newPos = this->changePlane( planes, endPos, &newPos, curFrame );
    }
    if(newPos.isNull( )) {
        this->finish( curFrame );
        mexPrintf("No New planes. Ending.\n");
        mexEvalString("drawnow");
    } else
        this->addPoint( newPos );
}

Point SimTrajectory::changePlane( std::vector<Plane> *planes, Point *oldPos, Point *newPos, int curFrame ) {
    // Find new plane
    //mexPrintf("Finding old plane\n"); mexEvalString("drawnow");
    Plane* oldPlane = Plane::findPlane( planes, *oldPos, 1 );
    //mexPrintf("Finding new plane\n"); mexEvalString("drawnow");
    Plane* newPlane = Plane::findPlane( planes, *newPos, 1 );
        
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

    

    // get the distance from the border so we can split the trajectory there
    double d = ( (x2-x1).cross(x0-x1) ).toMatrix( ).mag( ) / ( x2-x1 ).toMatrix( ).mag( );
    
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
    
    // Iterate through all planes
    std::vector<Plane>::iterator pIt;
    
    std::map<int,Line> leftnright;
    leftnright[0] = Line( (*planes)[0].boundaries[0],(*planes)[0].boundaries[1] );
    leftnright[1] = Line( (*planes)[0].boundaries[0],(*planes)[0].boundaries[1] );
    for(pIt = planes->begin(); pIt != planes->end( ); pIt++ ) {
        // look for furthest left hand line (use centroid)
        for( unsigned int p=0;p<pIt->boundaries.size( ); p++ )
        {
            int p2 = p+1;
            if(p2 >= pIt->boundaries.size( )) {
                p2 = 0;
            }
            Point pt1 = pIt->boundaries.at(p);
            Point pt2 = pIt->boundaries.at(p2);
            Point centroid = (pt1+pt2)/2;
            if( centroid.getX( ) < leftnright[0].centroid().getX( ) ) {
                //mexPrintf("Setting left edge: %s -> %s\n", centroid.toStr3D( ).c_str( ),leftnright[0].centroid().toStr3D( ).c_str( ));
                leftnright[0] = Line(pt1,pt2);
                mexEvalString("drawnow");
            } 
            if( centroid.getX() > leftnright[1].centroid().getX( ) ) {
                //mexPrintf("Setting right edge: %s -> %s\n", centroid.toStr3D( ).c_str( ),leftnright[0].centroid().toStr3D( ).c_str( ));

                leftnright[1] = Line(pt1,pt2);
                mexEvalString("drawnow");
            }
        }
    }
    
    double r = myrand(1);
    int plane_id = (int)round(r);
    
    int startEnd = 0;
    
    double r2 = myrand(1);
            
    this->reversal = false;
    if( plane_id ) {
        this->reversal = true;
    }
    Point start = r2*leftnright[plane_id].start + (1-r2)*leftnright[plane_id].end;
    //mexPrintf("R: %3.5f, Plane ID: %d\n",r,plane_id);
    //std::vector<Point> boundaries = planes->at(plane_id).boundaries;
    //float newY = boundaries.at(0).Y + myrand(1)*boundaries.at(2).Y;
    //Point start = Point(boundaries.at(startEnd).X, newY, boundaries.at(startEnd).Z);
    
    this->addPoint( start );
    
}