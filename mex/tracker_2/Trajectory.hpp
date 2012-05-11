#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/video/tracking.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"

#include "mex.h"

class Trajectory
{
    private:
        std::vector< cv::Point2f > positions;
        std::vector< int > times;
        int id;
        bool isOpen;

    public:
        Trajectory(  );
        void addPosition( cv::Point2f pos, int time );

        std::vector<cv::Point2f> getPositions( );
        std::vector<int> getTimes( );

        void close( );

        void toMatlab( double *posPtr, double *timePtr );
        void draw( cv::Mat frame );
};
