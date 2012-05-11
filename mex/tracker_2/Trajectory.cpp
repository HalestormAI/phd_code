#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/video/tracking.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"

#include "mex.h"
#include "Trajectory.hpp"
Trajectory::Trajectory( ) {
    
    this->positions = std::vector<cv::Point2f>( );
    this->times = std::vector<int>( );

    this->isOpen = 1;
}

void Trajectory::addPosition( cv::Point2f pos, int time ) {
    this->positions.push_back( pos );
    this->times.push_back( time );
}

std::vector<cv::Point2f> Trajectory::getPositions( ) {
    return this->positions;
}

std::vector<int> Trajectory::getTimes( ) {
    return this->times;
}

void Trajectory::close( ) {
    this->isOpen = 0;
}

void Trajectory::toMatlab( double *posPtr, double *timePtr ) {

    int tcounter = 0;
    int pcounter = 0;
    
    for( int i=0; i < this->positions.size( ); i++ ) {
        *(timePtr+tcounter++) = this->times.at(i);
        *(posPtr+pcounter++) = this->positions.at(i).x;
        *(posPtr+pcounter++) = this->positions.at(i).y;
    }
}

void Trajectory::draw( cv::Mat trajImg ) {

    CvScalar( colour );

    if( this->isOpen )
        colour = cvScalar( 0, 0, 255 );
    else
        colour = cvScalar( 255, 0, 0 );
    
    std::vector<cv::Point2f>::iterator it;

    for( it = this->positions.begin(); it != this->positions.end( ); it++ ) {
        if( (it+1) != this->positions.end( ) ) {
            cv::line( trajImg, *it, *(it+1), colour,1);
        }
    }
}
