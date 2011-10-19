#ifndef TRACKLET_H
#define TRACKLET_H

#include "cv.h"
#include "functions.h"

namespace IJH {  
  class Tracklet
  {


      public:
      
          CvPoint start;
          CvPoint end;
          int angle;
          float speed;
          int creationFrame;
          std::vector<CvPoint> passPoints;

          Tracklet( CvPoint *s, CvPoint *e, int f );
          Tracklet( );
          
          float getAngle( Tracklet *up );
          void draw(IplImage *im, CvScalar *colour, int width = 1);
         
          static CvScalar getColour( int angle );
          int getPassPoints( );
  };
}
#endif
