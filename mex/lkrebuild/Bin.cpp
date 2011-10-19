#include "Bin.h"

IJH::Bin::Bin( ) {
  
  x = y = 0;
  initdrn();
}

IJH::Bin::Bin( int xx, int yy ) {
  x = xx;
  y = yy;
  initdrn();            
}

void IJH::Bin::initdrn( ) { 
  for( int i = 0; i < NUM_DRN; ++i ) {
      directions[i] = 0;
  }
}

void IJH::Bin::increment( int angle ) {
  angle = angle % 360;
  float seg = 360 / (float)NUM_DRN;
  int b = (int) floor( angle / seg );
  if( b >= NUM_DRN || b < 0 ) {
      std::cerr << "Illegal array index in bin (" << x << "," << y
           << "): " << b << "." << std::endl;
  } else
      directions[b]++;
}

void IJH::Bin::generateBins( std::map<int,std::map<int,Bin> > *bins,
      int imw, int imh ) {
  
  // Create 32x32 bins
  int nbinsH = ceil( imw / (float)B_SIZE );
  int nbinsV = ceil( imh / (float)B_SIZE );
  
  
  for( int i = 0; i < nbinsV; i++ ) 
      for( int j = 0; j < nbinsH; j++ ) 
          (*bins)[i][j] = Bin( j*B_SIZE, i*B_SIZE );
}

std::vector<CvPoint> IJH::Bin::getBinIndices( IJH::Tracklet *t, IplImage *image ) {
  std::vector<CvPoint> idxs;
  
  std::vector<CvPoint>::iterator it;
  
  for( it=t->passPoints.begin();it != t->passPoints.end(); it++)
  {
      uint xpos = it->x/B_SIZE;
      uint ypos = it->y/B_SIZE;
      
      std::pair<int,int> numBins = IJH::Bin::getNumBins(image);
      
      if( xpos > numBins.first ) 
          mexPrintf("This bin's too big... %d. Max: %d\n", xpos, numBins.first);
      if( ypos > numBins.second ) 
          mexPrintf("This bin's too big... %d. Max: %d\n", ypos, numBins.second);
  mexEvalString("drawnow");
      
      idxs.push_back(cvPoint(xpos,ypos));
  }
  
	  IJH::removeDuplicates( idxs);
  return idxs;
}


std::pair<int,int> IJH::Bin::getNumBins( IplImage *im ) {
  // Returns a pair containing the number of bins horizontally
  // and vertically.
  int h = ceil(im->width / (float)IJH::Bin::B_SIZE);
  int v = ceil(im->height /(float)IJH::Bin::B_SIZE);
  
  return std::make_pair(h,v);
}
