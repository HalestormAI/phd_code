#include "functions.h"


double IJH::degToRad(double deg) {
      return PI/180*deg;
  }

double IJH::radToDeg(double rad) {
      return 180/PI*rad;
  }


float IJH::getColourWeight(float angle, bool p) {

      float w = (fabs(1-(angle/180.0)));
      if (p)
          std::cout << "Angle: " << angle << ", weight: " << w;
      return w;
  }

int IJH::bresenhamsAlgorithm(CvPoint *loc, CvPoint end, std::vector<CvPoint> &passPoints,
		  int i, int j) {
	  bool steep = abs(end.y - loc->y) > abs(end.x - loc->x);
	  int count = 0;
	  int tmp;
	  if (steep) {
		  tmp = loc->x;
		  loc->x = loc->y;
		  loc->y = tmp;

		  tmp = end.x;
		  end.x = end.y;
		  end.y = tmp;
	  }
	  if (loc->x > end.x) {
		  int tmp;
		  tmp = loc->x;
		  loc->x = end.x;
		  end.x = tmp;

		  tmp = loc->y;
		  loc->y = end.y;
		  end.y = tmp;
	  }
	  int startx = loc->x;

	  int dx = end.x - loc->x;
	  int dy = abs(end.y - loc->y);
	  float error = 0;
	  float derror = (float)(dy) / dx;

	  int ystep;
	  int y = loc->y;

	  if (loc->y < end.y)
		  ystep = 1;
	  else
		  ystep = -1;
	  for (int x = startx; x<end.x; x++) {
		  if (steep) {
			  loc->x = y;
			  loc->y = x;
		  } else {
			  loc->x = x;
			  loc->y = y;
		  }
		  if (count < abs(i)+abs(j)) {
			  passPoints.push_back( *loc);
			  count++;
			  error += derror;

			  if (error >= 0.5) {
				  y += ystep;
				  error -= 1;
			  }
		  } else {
			  mexPrintf("Beyond Boundaries (%d*%d) = %d : %d\n", i, j,
					  abs(i)+abs(j), count);
		  }
	  }
	  return count;
}
bool IJH::CvPoint_isequal(CvPoint p, CvPoint p2) {
	  if (p.x == p2.x && p.y == p2.y)
		  return true;
	  return false;
  }

void IJH::removeDuplicates(std::vector<CvPoint> &cvpoints) {
  std::vector<CvPoint>::iterator vitr;
  for (vitr = cvpoints.begin(); vitr != cvpoints.end()-1;) {
	  CvPoint pt1 = *vitr;
	  CvPoint pt2 = *(vitr+1);

	  if (CvPoint_isequal(pt1, pt2)) {
		  cvpoints.erase(vitr);
	  } else {
		  ++vitr;
	  }
  }
}

std::string IJH::parseTraj( std::vector<CvPoint> in ) {
	std::vector<CvPoint>::iterator it;
	std::stringstream out;
	for( it = in.begin(); it != in.end( ); it++ ) {
		out << "(" << it->x << "," << it->y << ")";
		if( (it+1) != in.end( ) ) {
			out << " => ";
		}
	}
	return out.str( );
}

void IJH::drawTraj( cv::Mat im, std::vector<CvPoint> in, CvScalar colour ) {


}
