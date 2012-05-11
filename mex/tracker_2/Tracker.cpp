#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/video/tracking.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"
#include <iostream>
#include <iomanip>
#include <vector>
#include <iterator>
#include <algorithm>
#include <cmath>
#include <sstream>
#include <fstream>
#include <sys/stat.h>
#include <sys/types.h>
#include <string>

#include "mex.h"
#include "matrix.h"
#include "Trajectory.cpp"

#define FD_ORB 0
#define FD_GFTT 1

#define FD_ALGORITHM FD_GFTT

int WINDOW_SIZE = 20;
float MINIMUM_DISTANCE = 1;
int MAX_POINTS = 1000;

bool need_to_init = 1;

bool open_display = true;

//std::map< int, std::vector< cv::Point2f > > trajectories;
//
std::vector< Trajectory > openTraj;
std::vector< Trajectory > doneTraj;
std::vector< Trajectory > allTraj;

cv::Mat firstFrame;

#if FD_ALGORITHM == FD_ORB
    std::string ROOT_DIR = "/home/ian/PhD/tracker_2/orbtest";
#elif FD_ALGORITHM == FD_GFTT
    std::string ROOT_DIR = "/home/ian/PhD/tracker_2/gftttest";
#endif



int main( int argc, char** argv ) {

    #if FD_ALGORITHM == FD_ORB
        std::cout << "Using ORB feature detector" << std::endl;
    #elif FD_ALGORITHM == FD_GFTT
        std::cout<< "Using GFTT feature detector" << std::endl;
    #endif

    if( std::string(argv[1]) == "-?" || std::string(argv[1]) == "--help" ) {
        std::cout << "Usage: OrbTest [options ...] input_file" << std::endl;
        std::cout << "Options: \n"
                  << "\t-d\t--minimum-distance\tThe minumum distance a point must be tracked (float)\n"
                  << "\t-w\t--klt-window-size\tThe size of the window for the KLT algorithm\n"
                  << "\t-p\t--max-points\t\tThe maximum number of points to be tracked at any one time\n"
                  << "\t-o\t--output-file\t\tThe output folder for tracked data" << std::endl;
        return 0;
    }
    // Parse cmd line args
    for( int i = 1; i < argc-1; i++ )
    {
        std::cout << "Arg[" << i << "]:" << std::string(argv[i]) << " (argc = " << argc << ")" << std::endl;

        if( ( std::string(argv[i]) == "-d" || std::string(argv[i]) == "--minimum-distance" ) && (i+1 < argc-1) ) {
            MINIMUM_DISTANCE = atof( argv[++i] );
        } else if( ( std::string(argv[i]) == "-w" || std::string(argv[i]) == "--klt-window-size" ) && (i+1 < argc-1) ) {
            WINDOW_SIZE = atoi( argv[++i] );
        } else if( ( std::string(argv[i]) == "-p" || std::string(argv[i]) == "--max-points" ) && (i+1 < argc-1) ) {
            MAX_POINTS = atoi( argv[++i] );
        } else if( ( std::string(argv[i]) == "-o" || std::string(argv[i]) == "--output-file" ) && (i+1 < argc-1) ) {
            ROOT_DIR = argv[++i];
        }
    }


    std::cout << "ROOT_DIR: " << ROOT_DIR << std::endl;
    cv::Mat prevImg, curImg;
    std::vector<cv::KeyPoint> prevOrbPt, curOrbPt;
    std::vector<cv::Point2f> prevPt, curPt;
    cv::VideoCapture cap;
    
    cap.open( argv[argc-1] );
    if( !cap.isOpened( ) ) {
        std::cout << "Failed to open stream: " << argv[1] << std::endl;
        return -1;
    }

    if( open_display ) 
        cv::namedWindow( "image", CV_WINDOW_NORMAL | CV_GUI_EXPANDED );
    
    int frameNo = 0;

    mkdir( ROOT_DIR.c_str( ), 0777 );
    mkdir( (ROOT_DIR+"/orb_trajectories").c_str( ), 0777 );
    mkdir( (ROOT_DIR+"/orb_salients").c_str( ), 0777 );

    for(;;) {
        cv::Mat frame;
        cap >> frame;
        if( frameNo == 0 )
            cap >> firstFrame;
        if( frame.empty( ) )
            break;

        frame.copyTo( curImg );
        cv::Mat prevPtImg, curPtImg, matchImg;
        curImg.copyTo( curPtImg );
        
        if( frameNo > 0 )
        {                  

            // LK Optical Flow Calculation            
            cv::Mat grey, prevGrey;
            cv::cvtColor(curImg, grey, CV_BGR2GRAY );
            cv::cvtColor(prevImg, prevGrey, CV_BGR2GRAY );

            std::vector<uchar> status;
            std::vector<float> err;
            cv::calcOpticalFlowPyrLK( prevGrey, grey, prevPt, curPt, status, err, cv::Size(WINDOW_SIZE,WINDOW_SIZE) );
            
            // Set up a temporary map for the next frame
            std::vector<cv::Point2f> tmpPts;

            std::vector<cv::Point2f>::iterator it;
            std::vector<cv::Point2f>::iterator pIt;
            for( int pos = curPt.size( ) - 1; pos >= 0; pos-- ) {                  

                it = curPt.begin( ) + pos;

                cv::circle( curPtImg, *it, 5, cv::Scalar(0,255,0), -1 );
                pIt = prevPt.begin( ) + pos;
                cv::circle(curPtImg, *pIt, 5, cv::Scalar(255,0,0),-1);

                // Work out the image-plane distances between points
                // in the two frames
                cv::Point2f diffPt = *pIt - *it;
                float imDist = sqrt(pow(diffPt.x,2) + pow(diffPt.y,2) );
                int posStatus = status.at(pos);

                if( posStatus && imDist > MINIMUM_DISTANCE ) {
                    cv::line( curPtImg, *pIt, *it, cv::Scalar(0,0,255), 2, CV_AA);
                    openTraj.at(pos).addPosition( *pIt, frameNo );
                    tmpPts.push_back(*it);
                } else {
                      need_to_init = 1;
                      if( openTraj.at(pos).getPositions( ).size( ) > 0 ) {
                          openTraj.at(pos).close( );
                          doneTraj.push_back(openTraj.at(pos));
                      }
                      openTraj.erase(openTraj.begin( ) + pos);
                } 
                
            }
            prevPt.clear( );
            curPt.clear( );
            reverse(tmpPts.begin( ), tmpPts.end( ) );
            prevPt = tmpPts;

            if( open_display ) 
                cv::imshow( "image", curPtImg );
            
            
            
            cv::Mat trajImg;
            frame.copyTo( trajImg );
            std::vector< Trajectory >::iterator tIter;
            for( tIter = openTraj.begin( ); tIter != openTraj.end( ); tIter++ ) {
                tIter->draw( trajImg );
            }
            for( tIter = doneTraj.begin( ); tIter != doneTraj.end( ); tIter++ ) {
                tIter->draw( trajImg );
            }

            std::stringstream trajFile,ptFile;
            trajFile << (ROOT_DIR+"/orb_trajectories/frame_").c_str( );
            trajFile << std::setw(8) << std::setfill( '0' ) << frameNo;
            trajFile << std::setw(1) << ".png";
            cv::imwrite(  trajFile.str( ), trajImg );

            ptFile << ROOT_DIR+"/orb_salients/frame_";
            ptFile << std::setw(8) << std::setfill( '0' ) << frameNo;
            ptFile << std::setw(1) << ".png";
            cv::imwrite(  ptFile.str( ), curPtImg );
            
        } 
        
        // Move current frame data to previous frame data 
        curImg.copyTo( prevImg );
        curPtImg.copyTo( prevPtImg );

        if( need_to_init ) {
            // Find ORB feature points on current frame
//            std::cout << "Need to find " << MAX_POINTS + 1 << "-" << prevPt.size( ) << " = " << MAX_POINTS + 1 - prevPt.size( ) << std::endl;
            #if FD_ALGORITHM == FD_ORB 
                cv::OrbFeatureDetector detect( MAX_POINTS+ 1 - prevPt.size( ));
            #elif FD_ALGORITHM == FD_GFTT
                cv::GoodFeaturesToTrackDetector detect( MAX_POINTS+ 1 - prevPt.size( ));
            #endif

            std::vector<cv::KeyPoint> tmpKpt;
            std::vector<cv::Point2f> tmpPt;

            detect.detect(curImg, tmpKpt, cv::Mat( ));
            cv::KeyPoint::convert( tmpKpt, tmpPt );

            // Insert openTraj spaces
            std::vector<cv::Point2f>::iterator ptIt;
            for( ptIt = tmpPt.begin( ) ; ptIt != tmpPt.end( ); ptIt++ ) {
                openTraj.push_back( Trajectory( ) );
            }
            // Copy new points onto end of prevPt vector.
            prevPt.insert(prevPt.end( ), tmpPt.begin( ), tmpPt.end( ));
            need_to_init = 0;
  //          std::cout << "Keypoints Detected: " << tmpPt.size( ) << std::endl;
        } 

        char k = cv::waitKey(5);
        if( int(k) == 'q' || int(k) == 'Q' )
            break;
        
        ++frameNo;
/*
        if( frameNo > 2 ) {
            drawTrajectories( frame, 1 );
            break;
            }
*/            
    }
    
    
    allTraj.insert( allTraj.end( ), doneTraj.begin(), doneTraj.end( ) );
    allTraj.insert( allTraj.end( ), openTraj.begin(), openTraj.end( ) );
    // Now write out trajectory lengths into a text-file
//     std::ofstream outFile( (ROOT_DIR+"/orb_trajectory_lengths.txt").c_str( ) );
//     std::vector< std::vector<cv::Point2f> >::iterator mIt;
//     for( mIt = allTraj.begin( ); mIt != allTraj.end( ); mIt++ ) {
//         outFile << mIt-allTraj.begin( ) << "\t" << mIt->size( ) << std::endl;
//     }
//     outFile.close( );
    //drawTrajectories( firstFrame,1 );
    return 0;
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    mwSize buflen;

    double *ml_tracks,*ml_times,*imgsize,*blocksz,*ml_bins,*binidx;
    unsigned char *ml_firstFrame;
    
    open_display = true;
    
    /* check for proper number of arguments */
    if(nrhs!=1) 
      mexErrMsgTxt("One input required - Video Path.");
    else if(nlhs != 2) 
      mexErrMsgTxt("Wrong number of output arguments: 2 required.");

    /* input must be a string */
    if ( mxIsChar(prhs[0]) != 1)
      mexErrMsgTxt("Input must be a string.");

    /* input must be a row vector */
    if (mxGetM(prhs[0])!=1)
      mexErrMsgTxt("Input must be a row vector.");

    /* get the length of the input string */
    buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;

    /* copy the string data from prhs[0] into a C string input_ buf.    */
    
    mexPrintf("Getting filename: \n");
    char *filename = mxArrayToString( prhs[0]);
    mexPrintf("Filename: %s\n", filename );
    
    char *args[2];
    args[0] = "Filename: ";
    args[1] = filename;
    
    
    mexPrintf("Running Main\n" );
    main( 2, args );
    
    // Output 1: Tracklets and times
    mwSize dims[2];
    dims[0] = allTraj.size( );
    dims[1] = 1;
    plhs[0] = mxCreateCellArray( 2, dims );
    plhs[1] = mxCreateCellArray( 2, dims );
    
    for( int i=0; i < allTraj.size( ); i++ ) {
        mxArray *posCell = mxCreateDoubleMatrix( 2, allTraj.at(i).getPositions( ).size( ), mxREAL );
        mxArray *timeCell = mxCreateDoubleMatrix( allTraj.at(i).getPositions( ).size( ), 1, mxREAL );
        double *posPtr = mxGetPr( posCell );
        double *timePtr = mxGetPr( timeCell );
        allTraj.at(i).toMatlab( posPtr, timePtr );
        mxSetCell( plhs[0], i, posCell );
        mxSetCell( plhs[1], i, timeCell );
    }
    

    return;
}