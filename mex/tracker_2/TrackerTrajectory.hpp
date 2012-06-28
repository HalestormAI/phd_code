
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
