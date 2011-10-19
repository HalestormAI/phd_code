#ifndef BIN_H
#define BIN_H
#include "Tracklet.h"
#include "functions.h"
#include "cv.h"

namespace IJH {
  class Bin
  {
      
    public:
      static const int B_SIZE = 32;
      static const int NUM_DRN = 8;
      int x;
      int y;
      
      int directions[NUM_DRN];
      
      Bin( );
      Bin( int xx, int yy );
      void initdrn( );
      void increment( int angle );
      static void generateBins( std::map<int,std::map<int,Bin> > *bins,int imw, int imh );

      static std::vector<CvPoint> getBinIndices( IJH::Tracklet *t, IplImage *image  );

      static std::pair<int,int> getNumBins( IplImage *im );
  };
}

#endif
