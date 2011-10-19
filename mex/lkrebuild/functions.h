#ifndef IJH_FUNC_H
#define IJH_FUNC_H
#include "cv.h"
#include "mex.h"
#include <iostream>
#include <string>
#include <sstream>
#define PI (3.141592653589793)

namespace IJH {

	double degToRad(double deg);
	double radToDeg(double rad);
	float getColourWeight(float angle, bool p);
	int bresenhamsAlgorithm(CvPoint *loc, CvPoint end, std::vector<CvPoint> &passPoints, int i, int j);
	bool CvPoint_isequal(CvPoint p, CvPoint p2);
	void removeDuplicates(std::vector<CvPoint> &cvpoints);
	std::string parseTraj( std::vector<CvPoint> in );
	void drawTraj( cv::Mat im, std::vector<CvPoint> in, CvScalar = cvScalar( 255, 0, 0) );
}

#endif
