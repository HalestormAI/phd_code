/*
 * main.cpp
 *
 *  Created on: 11 Oct 2011
 *      Author: sc06ijh
 */

#include "cv.h"
#include "highgui.h"
#include <time.h>
#include <iostream>
#include <iomanip>
#include <stdexcept>
#include <exception>
#include "functions.h"
#include <string>
#include <sys/stat.h>

const uint MAX_CORNERS = 500;
const uint win_size = 25;

const std::string fOutputRoot = "/usr/not-backed-up/trackeroutput";
int c_count = 0;
std::vector<cv::Point2f> corners_st;
std::vector<cv::Point2f> corners_nd;

std::vector<cv::Point2f> corners_tmp;
std::vector<uchar> trackStatus;
std::vector<float> trackErr;

std::vector<std::vector<cv::Point2f> > openTraj;
std::vector<std::vector<cv::Point2f> > closeTraj;
cv::Mat frame, firstFrame, cleanFrame, image, grey, prev_grey, img_tracklet, frameCountImg;

//std::map<int, std::map<int, IJH::Bin> > bins;

bool showWin = 1;

int mainLoop(int argc, std::string argv[]) {
	int need_to_init = 1;

    cv::namedWindow("quit catcher",CV_WINDOW_NORMAL);

	time_t rawtime;
	struct tm * timeinfo;
	char tbuffer[80];

	time( &rawtime );
	timeinfo = localtime( &rawtime );

	strftime(tbuffer, 80, "%d-%m-%y__%H-%M-%S", timeinfo);

	const std::string fOutputFolder( tbuffer );

	std::cout << "Creating folder " << fOutputRoot << "/" << fOutputFolder << std::endl;
	mkdir( (fOutputRoot+"/"+fOutputFolder).c_str( ), 0777 );




	cv::VideoCapture capture;

	if (argc >= 2) {
		mexPrintf("Opening file: %s", argv[1].c_str());
		capture = cv::VideoCapture(argv[1].c_str());
	} else {
		std::cerr << "No Filename Given" << std::endl;
	}
	if (!capture.isOpened()) {
		fprintf(stderr, "Could not initialise capturing...\n");
		return -1;
	}

	int frameNumber = 0;

	bool stepping = 0;

	for (;;) {

		int i;
		capture >> frame;

		if (!frame.data)
			break;

		if (!image.data) {
			frame.copyTo(firstFrame);
		}

		frame.copyTo(image);
		//frame.copyTo(cleanFrame);
		cv::cvtColor(frame, grey, CV_BGR2GRAY );

		if (need_to_init) {
			frame.copyTo(img_tracklet);

			/* automatic initialisation */

			if (corners_st.size() < MAX_CORNERS)
				c_count = MAX_CORNERS - corners_st.size();
			else
				c_count = MAX_CORNERS;
			//std::cout << "Frame " << frameNumber << ": Adding " << c_count << " corners." << std::endl;

			corners_tmp.clear();
			cv::goodFeaturesToTrack(grey, corners_tmp, c_count, 0.001, 10);

			corners_st.insert(corners_st.end(), corners_tmp.begin(),
					corners_tmp.end());

			for (uint i = 0; i < corners_tmp.size(); i++) {
				openTraj.push_back(std::vector<cv::Point2f>());
			}

			need_to_init = 0;
		}
		if (corners_st.size() > 0 && frameNumber > 0) {
			cv::calcOpticalFlowPyrLK(prev_grey, grey, corners_st, corners_nd,
					trackStatus, trackErr, cvSize(win_size, win_size));

			cv::Mat errorImg;
			frame.copyTo( errorImg );

			for (i = corners_nd.size() - 1; i > 0; i--) {
				// Remove any points which do not contain tracks
				cv::circle(image, corners_st.at(i), 2,cvScalar(0,255,0),-1);
				cv::circle(image, corners_nd.at(i), 2,cvScalar(0,0,255),-1);
				cv::line(image, corners_st.at(i), corners_nd.at(i), cvScalar(255,0,0) );

				if (trackStatus.at(i)) {
					try {
						std::vector< cv::Point2f> d = openTraj.at(i);
					} catch( ... ) {
						std::cerr << "framenumber: " << frameNumber << "openTraj Size: " << openTraj.size( ) <<  ", Index: " << i << std::endl;
						exit(1);
					}


					cv::Point mag = ( corners_nd.at(i) - corners_st.at(i) );
					float curSpd = sqrt( pow(mag.x,2) + pow(mag.y,2) );

					bool crazyfast = false;
					if( curSpd > image.rows/2 ) {
						crazyfast = true;
						std::cout << "Maximum Speed Breached, Frame " << frameNumber << std::endl;
						cv::circle(errorImg, corners_st.at(i), 2,cvScalar(0,255,0),-1);
						cv::circle(errorImg, corners_nd.at(i), 2,cvScalar(0,0,255),-1);
						cv::line(errorImg, corners_st.at(i), corners_nd.at(i), cvScalar(255,0,0) );
						cv::imshow( "Error", errorImg );
					}
					std::vector<cv::Point2f>::iterator trajp = openTraj.at(i).end()-1;
					cv::Point2f *trajst = &corners_st.at(i);

					if( openTraj.at(i).size( ) > 0 && (*trajst != *trajp )) {
						std::cout << "Frame " << frameNumber << ", No Match: (" << trajp->x << "," << trajp->y << ") != (";
						std::cout << trajst->x << "," << trajst->y << ")" << std::endl;
						trackStatus[i] = 0;
					}

					// If a match was found, and > 10 frames have been recorded,
					if(openTraj.at(i).size( ) > 10) {
						// Check motion over those 10 frames
						// If mean(l) < 2, don't save
						cv::Point2f p1,p2,dxy;

						float sumspeeds = 0;
						for( int b = 1; b < 11; b++ ) {
							p1 = openTraj.at(i).at((openTraj.at(i).size( )-1)-(b-1));
							p2 = openTraj.at(i).at((openTraj.at(i).size( )-1)-(b));

						    dxy = p1-p2;

						    float spd = sqrt( pow(dxy.x,2) + pow(dxy.y,2) );
//						    if( spd > frame.rows/2 ) {
//						    	crazyfast = true;
//						    	std::cout << "Something very odd has occurred..." << std::endl;
//						    	std::cout << "Start: (" << p1.x << "," << p1.y << ")";
//						    	std::cout << " => (" << p2.x << "," << p2.y << ")" << std::endl;
//						    	break;
//						    }
						    sumspeeds += spd;
						}

						float meanspeed = sumspeeds/10;
						if( meanspeed < 2 || crazyfast) {
							trackStatus[i] = 0;
						}

					}
				}

				if( trackStatus.at(i) ) {
					// Append this end-point to the back of the trajectory
					openTraj.at(i).push_back(corners_nd.at(i));
				} else {
					// otherwise, move the trajectory to closed
					need_to_init = 1;
					closeTraj.push_back(openTraj.at(i));
					openTraj.erase(openTraj.begin() + i);
				}

			}

			// Move all valid end-points over to start-point vector
			corners_st.clear();
			for (uint i = 0; i < corners_nd.size(); i++)
				if (trackStatus.at(i))
					corners_st.push_back(corners_nd.at(i));
			corners_nd.clear();
			trackStatus.clear( );

		}

		 // DRAWING AND SAING
		cv::Mat trjimg;
		frame.copyTo( trjimg );

		std::vector<std::vector<cv::Point2f> >::iterator it;
		std::vector<cv::Point2f>::iterator it2;
		CvScalar colour = cvScalar( 0,0, 255 );
		for( it = closeTraj.begin(); it != closeTraj.end(); it++ ) {
			for( it2 = it->begin(); it2 != it->end( ); it2++ ) {
				if( (it2+1) != it->end( ) ) {
					cv::line( trjimg, *it2, *(it2+1), colour,1);
				}
			}
		}
		colour = cvScalar( 255,0,0 );
		for( it = openTraj.begin(); it != openTraj.end(); it++ ) {
			for( it2 = it->begin(); it2 != it->end( ); it2++ ) {
				if( (it2+1) != it->end( ) ) {
					cv::line( trjimg, *it2, *(it2+1), colour,1);
				}
			}
		}

		//cv::imshow("Trajectories", trjimg);
		//cv::imshow("Start-End Points", image);

		std::stringstream fnstream, frameStream, fnStream2;
		frameStream << std::setw( 8 ) << std::setfill( '0' ) << frameNumber;
		fnStream2 << fOutputRoot << "/" << fOutputFolder << "/" << "salient_" << frameStream.str( );
		fnStream2 << ".jpg";
		fnstream << fOutputRoot << "/" << fOutputFolder << "/" << "traj_" << frameStream.str( );
		fnstream << ".jpg";

		int baseline = 0;
		cv::Size textSize = cv::getTextSize( frameStream.str( ), cv::FONT_HERSHEY_SIMPLEX,
						0.5, 3, &baseline);
		baseline += 3;

		cv::Point textOrg((trjimg.cols - textSize.width-10),
					  (trjimg.rows - textSize.height-10));

		cv::rectangle(trjimg, textOrg - cv::Point(20,20) ,
					  textOrg + cv::Point(textSize.width+20, -textSize.height+20),
					  cv::Scalar(0,0,0),-1);
		cv::putText(trjimg, frameStream.str( ), textOrg, cv::FONT_HERSHEY_SIMPLEX, 0.5,
					cv::Scalar::all(255), 1, CV_AA);
		cv::rectangle(image, textOrg - cv::Point(20,20) ,
					  textOrg + cv::Point(textSize.width+20, -textSize.height+20),
					  cv::Scalar(0,0,0),-1);
		cv::putText(image, frameStream.str( ), textOrg, cv::FONT_HERSHEY_SIMPLEX, 0.5,
					cv::Scalar::all(255), 1, CV_AA);

		frameCountImg = cv::Mat::zeros(textSize.height+20,textSize.width+20,trjimg.type());

		cv::putText(frameCountImg, frameStream.str( ), cv::Point(10,textSize.height+10), cv::FONT_HERSHEY_SIMPLEX, 0.5,
					cv::Scalar::all(255), 1, CV_AA);

		cv::rectangle(image, textOrg - cv::Point(20,20) ,
					  textOrg + cv::Point(textSize.width+20, -textSize.height+20),
					  cv::Scalar(0,0,0),-1);
		cv::putText(image, frameStream.str( ), textOrg, cv::FONT_HERSHEY_SIMPLEX, 0.5,
					cv::Scalar::all(255), 1, CV_AA);

		const std::string filename = fnstream.str( );

		// Handle keypresses (this bit is a tad messy...)
		cv::imwrite( filename, trjimg );
		cv::imwrite( fnStream2.str( ), image );
		if( showWin ) {
			cv::imshow( "Trajectories", trjimg );
			cv::imshow( "End Points", image );
		} else if( !(frameNumber%10) ) {
			std::cout << "Frame Number: "  << frameNumber << std::endl;
		}
		cv::imshow( "quit catcher", frameCountImg );
		int k = cvWaitKey(2);
		if( char(k) == 's' || char(k) == 'S' ) {
			stepping = 1 - stepping;
		}
		if( char(k) == ' ' || stepping )
			k = cv::waitKey( );
		if( char(k) == 'q' || char(k) == 'Q' )
			break;
		if( char(k) == 'w' || char(k) == 'W' )
			showWin = 1 - showWin;
		if( char(k) == 's' || char(k) == 'S' ) {
			stepping = 1 - stepping;
		}

		std::swap(prev_grey, grey);
		frameNumber++;

	}

	// We're all done, so any trajectories that weren't finished, are now
	closeTraj.insert(closeTraj.end(), openTraj.begin(), openTraj.end());
	openTraj.clear( );

	return 0;
}

void formatTrajsForMatlab( std::vector< std::vector< cv::Point2f > > *traj, mxArray** tMatlab )
{
    double  *pointer;
    const mwSize dims = traj->size( );

    *tMatlab = mxCreateCellArray(1, &dims);
    pointer = mxGetPr(*tMatlab);

    std::vector < std::vector< cv::Point2f > >::iterator it;
    std::vector< cv::Point2f >::iterator it2;
    int cIndex = 0;
    /* Copy data into the mxArray */
    for ( it = traj->begin(); it != traj->end(); it++ ) {
    	std::vector< cv::Point2f > vec = *it;

        double *pt;
        mxArray *arr = mxCreateNumericMatrix( 2, vec.size( ), mxDOUBLE_CLASS, mxREAL );
        pt = mxGetPr(arr);
        int index = 0;

        for( it2 = vec.begin( ); it2 != vec.end( ); it2++ ) {
            cv::Point2f p = *it2;
            pt[index++] = p.x;
            pt[index++] = p.y;
        }

        mxSetCell( *tMatlab, cIndex++, arr );
    }

}
void Ipl2MatlabImage( IplImage *in, unsigned char *op_ptr, mwSize dims[] )
{


   /* for (int i = 0; i < in->width*in->height*3; i++)
    {
        printf("%f,", ((float*)in->imageData)[i+1])
       *(out+i) = ((float*)in->imageData)[i+1];
    }
    ;*/

//     printf("Dims: [%d, %d, %d]\n", dims[0],dims[1],dims[2] );
//     printf("Img: [%d, %d, %d,%d]\n", in->height,in->width,in->widthStep,in->imageSize );
    int idx;
//     cvSaveImage("ftest.jpg",in);
 //   mexPrintf("First pixel: %d,%d,%d\n", (unsigned char)in->imageData[2],(unsigned char)in->imageData[1],(unsigned char)in->imageData[0]);


        for(uint x=0 ; x<dims[1] ; x++){
          for(uint y=0 ;y<dims[0] ;y++,op_ptr++){
              idx = in->nChannels*x+2+y*in->widthStep;
              //printf( "(x,y) = (%d,%d), idx = (%d), C(R): %c", x,y,idx, (float)in->imageData[3*x+2+y*in->widthStep] );
            *op_ptr = (unsigned char)in->imageData[idx] ;
          }
        }
        for(uint x=0 ; x<dims[1] ; x++){
          for(uint y=0 ;y<dims[0] ;y++,op_ptr++){
              idx = in->nChannels*x+1+y*in->widthStep;
              //printf( "(x,y) = (%d,%d), idx = (%d), C(R): %c", x,y,idx, (float)in->imageData[3*x+2+y*in->widthStep] );
            *op_ptr = (unsigned char)in->imageData[idx] ;
          }
        }
        for(uint x=0 ; x<dims[1] ; x++){
          for(uint y=0 ;y<dims[0] ;y++,op_ptr++){
              idx = in->nChannels*x+y*in->widthStep;
              //printf( "(x,y) = (%d,%d), idx = (%d), C(R): %c", x,y,idx, (float)in->imageData[3*x+2+y*in->widthStep] );
            *op_ptr = (unsigned char)in->imageData[idx] ;
          }
        }


    printf("Managed to finish conversion.\n\n");
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

    mwSize buflen;

    unsigned char *ml_firstFrame;

    /* check for proper number of arguments */
    if(nrhs!=1)
      mexErrMsgTxt("One input required - Video Path.");
    else if(nlhs != 2)
      mexErrMsgTxt("Wrong number of output arguments: [trajectories,frame].");

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
    std::string args[2];

    mexPrintf("Building args list\n");
    args[0] = "calling...";
    mexPrintf("%s, ", args[0].c_str( ));
    args[1] = filename;
    mexPrintf("%s\n", args[1].c_str( ));
    mexPrintf("Args list built.\n");
    mexEvalString("drawnow");

    mainLoop( 2, args );

    formatTrajsForMatlab( &closeTraj, &plhs[0] );
    mexPrintf("Tracklets formatted for matlab\n");
    mexEvalString("drawnow");

    // Legacy support to IplImage to save rewriting the converter function!
    IplImage ffimg = firstFrame;

    mwSize dims[3];
    dims[1] = ffimg.width;
    dims[0] = ffimg.height;
    dims[2] = 3;

    // Output 2: First frame as image
    plhs[1] = mxCreateNumericArray(3,dims, mxUINT8_CLASS, mxREAL);
	ml_firstFrame = (unsigned char *) mxGetPr(plhs[1]);
    Ipl2MatlabImage( &ffimg, ml_firstFrame, dims);

    return;
}

int main(int argc, char** argv) {

	// open frame of video

	std::string args[2];
	args[0] = std::string(argv[0]);
	args[1] = std::string(argv[1]);

	mainLoop(argc, args);

	return 1;
}
