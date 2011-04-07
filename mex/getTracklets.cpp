/* Demo of modified Lucas-Kanade optical flow algorithm.
   See the printf below */

#ifdef _CH_
#pragma package <opencv>
#endif

#include "cv.h"
#include "highgui.h"
#include <iostream>
#include <fstream>
#include <ctype.h>
#include <map>
#include <vector>
#include <set>
#include <iterator>
#include <sstream>
#include <string>
#include <iomanip>
#include "mex.h"
#include "matrix.h"

#define PI (3.141592653589793)
using namespace std;

double degToRad(double deg) {
    return PI/180*deg;
}

double radToDeg(double rad) {
    return 180/PI*rad;
}


float getColourWeight(float angle, bool p) {

    float w = (fabs(1-(angle/180.0)));
    if (p)
        cout << "Angle: " << angle << ", weight: " << w;
    return w;
}


bool nodisplay = false;
class Tracklet
{


    public:
    
        CvPoint start;
        CvPoint end;
        int angle;
        float speed;
        int creationFrame;

        Tracklet( CvPoint *s, CvPoint *e, int f ) {
            start = *s;
            end = *e;
            creationFrame = f;

            float dx = abs( s->x - e->x );
            float dy = abs( s->y - e->y );

            speed = sqrt( dx*dx + dy*dy );
            angle = -1;
//            angle = (int)getAngle( );
        }

        Tracklet( ) {
            start = cvPoint( 0,0 );
            end   = cvPoint( 0,0 );
            speed = 0;
        }
        
        
       float getAngle( Tracklet *up ) {

          // Return cached angle if we've already worked it out
          if (angle != -1)
              return angle;

          // Get change in x and y for this vector
          int dx = end.x - start.x;
          int dy = end.y - start.y;

          // Get change in x and y for up vector
          int udx = up->end.x - up->start.x;
          int udy = up->end.y - up->start.y;

          // Get dot product a . b
          // (a1*b1 + a2*b2)
          double vDotU = dx*udx + dy*udy;

          // |a| and |b|
          double magU = speed;
          double magV = up->speed;

          // cos(a) = (a . b) / (|a||b|) 
          double cosAlpha = vDotU / (magU*magV);

          double a = radToDeg(acos(cosAlpha));

          // Hack for dot product only handling 0 < x < 180
          if (start.x > end.x) {
            a+=180;
          }

          // Reverse so dir[0] = up
          a+=180;

          // Ensure 0 < a < 360
          a = int(a)%360;

          if (isnan(a) ) {
              cout << "Angle IsNAN" << endl;
              return 0;
          } else {
              angle = a;
              return angle;
          }

    }
    
    void draw(IplImage *im, CvScalar *colour, int width = 1) {
        //CvScalar colour = cvScalar(0, g, 0);

        if (width > 0)
            cvLine(im, start, end, *colour, width);

        // add circle to end point
        //cvCircle(im, nd, 3, *colour, -1, CV_AA, 0);
    }

    static CvScalar getColour( int angle ) {

        CvScalar col;

        int r = (int) 255 * getColourWeight( (angle) % 360, 0);
        int g = (int) 255 * getColourWeight( (angle+120) % 360, 0);
        int b = (int) 255 * getColourWeight( (angle+240) % 360, 0);

        col = cvScalar( b, g, r );

        return col;

    }        

};

IplImage *image = 0, *grey = 0, *prev_grey = 0, *pyramid = 0, *prev_pyramid = 0, *swap_temp, *cleanImage = 0, *img_tracklet = 0, *img_tracklet_base = 0;

int win_size = 10;
const int MAX_COUNT = 500;
const int MINSPEED = 3;
const int FPS = 25;

CvPoint2D32f* points[2] = {0,0}, *swap_points;
char* status = 0;
int c_count = 0;
int need_to_init = 0;
int night_mode = 0;
int flags = 0;
int add_remove_pt = 0;
int trackids[ MAX_COUNT ];
CvPoint pt;
Tracklet up;
int initNumber = 0;
int lastNumTracklets = 0;
int zeroHist = 0;
bool zeroHistOutput = true;
int sectionID = -1;

bool outputFrameSpeeds = false;
bool outputTotalSpeeds = false;

map<int, CvPoint> startPoints;
map<int, CvPoint> endPoints;

string outputfn_base = "";

struct trackSpeedOrder
{
  bool operator()(const Tracklet s1, const Tracklet s2) const
  {
    return s1.speed < s2.speed;
  }
};

set<Tracklet,trackSpeedOrder> frameTracklets;
set<Tracklet,trackSpeedOrder> sectionTracklets;
set<Tracklet,trackSpeedOrder> tracklets;

void on_mouse( int event, int x, int y, int flags, void* param )
{
    if( !image )
        return;

    if( image->origin )
        y = image->height - y;

    if( event == CV_EVENT_LBUTTONDOWN )
    {
        pt = cvPoint(x,y);
    } else if ( event == CV_EVENT_RBUTTONDOWN ) {
      //  cvSaveImage( "trackeroutput/scene.jpg", cleanImage );
       // cvSaveImage( "salients.jpg", image );
        //cvSaveImage( "tracklets.jpg", img_tracklet );
        
      // Save all tracklet speeds for last frame
      outputFrameSpeeds = true;
    }
}
void on_mouse2( int event, int x, int y, int flags, void* param )
{
    if( !image )
        return;

    if( image->origin )
        y = image->height - y;

    if( event == CV_EVENT_LBUTTONDOWN )
    {
      outputTotalSpeeds = true;
    } else if ( event == CV_EVENT_RBUTTONDOWN ) {
      outputFrameSpeeds = true;
    }
}


void outputSpeedDist( set<Tracklet, trackSpeedOrder> *tks ) {

    set<Tracklet,trackSpeedOrder>::iterator tI;

    cout << "Speed Distribution Output" << endl;

    stringstream lst;

    for( tI = tks->begin( ) ; tI != tks->end( ) ; tI++ ) {
        lst << tI->speed << " ";
    }
    
    ofstream fl;
    stringstream fn;
    if( sectionID > -1 ) {
        fn << outputfn_base << "-section-" << sectionID << ".txt";
    } else {
        fn << outputfn_base << ".txt";
    }
    fl.open( fn.str( ).c_str( ) );
    fl << lst.str( ).substr( 0, lst.str( ).size( )-2 );
    fl.close( );
    cout << lst.str( ).substr( 0, lst.str( ).size( )-2 ) << endl;
}


IplImage *firstFrame;

int mainLoop( int argc, string argv[] )
{
 CvCapture* capture = 0;
   need_to_init = 1; 

   
    if( argc == 1 || (argc == 2 && strlen(argv[1].c_str( )) == 1 && isdigit(argv[1].c_str( )[0])))
        capture = cvCaptureFromCAM( argc == 2 ? argv[1][0] - '0' : 0 );
    else if( argc >= 2 ) {
        
        mexPrintf("Opening file: %s", argv[1].c_str( ));
        capture = cvCaptureFromAVI( argv[1].c_str() );
    }
    if( argc > 2 ) {
        outputfn_base = argv[2];
    } else {
        outputfn_base = "speed_vals";
    }
    if( argc > 3 ) {
        string display( argv[3] );
        string shouldbe = "--nodisplay";
        if( display.compare(shouldbe) == 0 ) {
            cout << "STDOUT ONLY MODE ACTIVATED" << endl;
            nodisplay = true;
        } else {
            stringstream os;
            os << "3rd Arg: " << display << endl;
            
            mexPrintf( "%s\n", os.str( ).c_str( ) );

            }

    }
    if( !capture )
    {
        fprintf(stderr,"Could not initialize capturing...\n");
        return -1;
    }

    if(!nodisplay) {
        //cvNamedWindow( "LkDemo", 0 );
        //cvNamedWindow( "Tracklets", 0 );
        //cvSetMouseCallback( "LkDemo", on_mouse, 0 );
        //cvSetMouseCallback( "Tracklets", on_mouse2, 0 );
    }
    int frameNumber = 0;

    for(;;)
    {
        IplImage* frame = 0;
        int i, k, c, l;

        frame = cvQueryFrame( capture );
        if( !frame )
            break;

        if( !image )
        {
            /* allocate all the buffers */
            image = cvCreateImage( cvGetSize(frame), 8, 3 );
            firstFrame = cvCreateImage( cvGetSize(frame), 8, 3 );
            img_tracklet = cvCreateImage( cvGetSize(frame), 8, 3 );
            img_tracklet_base = cvCreateImage( cvGetSize(frame), 8, 3 );
            cleanImage = cvCreateImage( cvGetSize( frame ), 8 , 3 );
            image->origin = frame->origin;
            grey = cvCreateImage( cvGetSize(frame), 8, 1 );
            prev_grey = cvCreateImage( cvGetSize(frame), 8, 1 );
            pyramid = cvCreateImage( cvGetSize(frame), 8, 1 );
            prev_pyramid = cvCreateImage( cvGetSize(frame), 8, 1 );
            points[0] = (CvPoint2D32f*)cvAlloc(MAX_COUNT*sizeof(points[0][0]));
            points[1] = (CvPoint2D32f*)cvAlloc(MAX_COUNT*sizeof(points[0][0]));
            status = (char*)cvAlloc(MAX_COUNT);
            flags = 0;
        }

        cvCopy( frame, image, 0 );
        cvCopy( frame, firstFrame, 0 );
        cvCopy( frame, cleanImage, 0 );
        

        cvCvtColor( image, grey, CV_BGR2GRAY );

        if( night_mode )
            cvZero( image );
        
        if( need_to_init )
        {
          //  tracklets.clear( );

            cvCopy( frame, img_tracklet, 0 );
            /* automatic initialization */
            IplImage* eig = cvCreateImage( cvGetSize(grey), 32, 1 );
            IplImage* temp = cvCreateImage( cvGetSize(grey), 32, 1 );
            double quality = 0.01;
            double min_distance = 10;

            c_count = MAX_COUNT;
            cvGoodFeaturesToTrack( grey, eig, temp, points[1], &c_count,
                                   quality, min_distance, 0, 3, 0, 0.04 );
                      
            //REMOVED AS IT DESTROYS MATLAB :S
            /*cvFindCornerSubPix( grey, points[1], c_count,
                cvSize(win_size,win_size), cvSize(-1,-1),
                cvTermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.03));*/
            
            cvReleaseImage( &eig );
            cvReleaseImage( &temp );
            
            for( i = 0; i < c_count; i++ ) {
                trackids[i] = i;
                startPoints[i] = cvPointFrom32f( points[1][i] );
            }

            need_to_init = 0;
        }
        else if( c_count > 0 )
        {
            cvCalcOpticalFlowPyrLK( prev_grey, grey, prev_pyramid, pyramid,
                points[0], points[1], c_count, cvSize(win_size,win_size), 3, status, 0,
                cvTermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.03), flags );
            flags |= CV_LKFLOW_PYR_A_READY;
            for( i = k = 0; i < c_count; i++ )
            {
                
                
                // Remove any points which do not contain tracks
                if( status[i] ) {
                    // Maintain id for startPoints. k is existing point, i is original
                    trackids[k] = trackids[i];
                    points[1][k] = points[1][i];
                    k++;
                    cvCircle( image, cvPointFrom32f(points[1][i]), 3, CV_RGB(0,255,0), -1, 8,0);
                } else
                    continue;
                
            }
            c_count = k;
        }

    

        if(frameNumber %  FPS == 0) {
        
            if( outputFrameSpeeds ) {
            //    outputSpeedDist( &frameTracklets );
                outputFrameSpeeds = false;
            }
            if( outputTotalSpeeds ) {
         //       outputSpeedDist( &tracklets );
                outputTotalSpeeds = false;
            }
            
            
            if( frameTracklets.size( ) == 0 ) {
         //       cout << "Zero tracklets, consecutive: " << ++zeroHist << endl;
                if( zeroHist > 1000 && zeroHistOutput ) {
                    zeroHistOutput = false;
                    ++sectionID;
                 //   outputSpeedDist( &sectionTracklets );
                //    sectionTracklets.clear( );
                }
                    
            } else {
                zeroHist = 0;
                zeroHistOutput = true;
            }
            frameTracklets.clear( );
            if(c_count) {
                for(i = l = 0; i < c_count; i++ ) {
                    
                    CvPoint s = startPoints[trackids[i]];
                    CvPoint e = cvPointFrom32f( points[1][i] );
                    
                    
                    // Build up vector
                    CvPoint uS = cvPoint(s.x,s.y);
                    CvPoint uE = cvPoint(s.x,s.y + 1);
                    up = Tracklet( &uS , &uE, 0 );

                    Tracklet t = Tracklet( &s, &e, frameNumber );                
                    if( t.speed > MINSPEED ) {
                        t.getAngle( &up );        
                        CvScalar c = Tracklet::getColour( t.angle );
                        //cout << "(" << t.start.x << "," << t.start.y << ") - " << "(" << t.end.x << "," << t.end.y << ")" << endl;

                        if(!nodisplay) t.draw( img_tracklet, &c, 2);
                        if(!nodisplay) t.draw( img_tracklet_base, &c, 2);
                        tracklets.insert( t );
                        frameTracklets.insert( t );
                        sectionTracklets.insert( t );
                        ++l;
                    }
                }
            }
            need_to_init = 1;

            
            string folder = "trackeroutput/";
            string num;
            stringstream numStream;
            numStream << setfill('0') << setw(5) << initNumber;
            num = numStream.str( );
            string file = folder + "scene_" + num + ".jpg"; 
            cvSaveImage( file.c_str( ), cleanImage );
            file = folder + "salients_" + num + ".jpg"; 
            cvSaveImage( file.c_str( ), image );
            file = folder + "tracklets_" + num + ".jpg"; 
           // cvSaveImage( file.c_str( ), img_tracklet );
            cvSaveImage( file.c_str( ), img_tracklet_base );
//            if(!nodisplay) cvShowImage( "Tracklets", img_tracklet );
            //if(!nodisplay) cvShowImage( "Tracklets", img_tracklet_base );
        }
        
        CV_SWAP( prev_grey, grey, swap_temp );
        CV_SWAP( prev_pyramid, pyramid, swap_temp );
        CV_SWAP( points[0], points[1], swap_points );
 //       if(!nodisplay) cvShowImage( "LkDemo", image );

        if(need_to_init) {
            string folder = "trackeroutput/";
            string num;
            stringstream numStream;
            numStream << setfill('0') << setw(5) << initNumber;
            num = numStream.str( );
            string file = folder + "scene_" + num + ".jpg"; 
            cvSaveImage( file.c_str( ), cleanImage );
            file = folder + "salients_" + num + ".jpg"; 
            cvSaveImage( file.c_str( ), image );
            file = folder + "tracklets_" + num + ".jpg"; 
            cvSaveImage( file.c_str( ), img_tracklet );
            mexPrintf("File Saved");
            initNumber++;
        }
        frameNumber++;
        
        c = cvWaitKey(10);
        if( (char)c == 27 )
            break;
        switch( (char) c )
        {
        case 'r':
            need_to_init = 1;
            break;
        case 'c':
            c_count = 0;
            break;
        case 'n':
            night_mode ^= 1;
            break;
        default:
            ;
        }

    }

    ++sectionID;
    //outputSpeedDist( &sectionTracklets );
    //outputSpeedDist( &tracklets );
    cvReleaseCapture( &capture );
//    if(!nodisplay) cvDestroyWindow("LkDemo");
    return 0;
}



void formatTrackletsForMatlab( set<Tracklet,trackSpeedOrder> *tracklets, double* tMatlab )
{

    set<Tracklet,trackSpeedOrder>::iterator tI;
    
    int counter = 0;
    for( tI = tracklets->begin( ) ; tI != tracklets->end( ) ; tI++ ) 
    {
       // printf("%d,%d",tI->start.x,tI->start.y);
        *(tMatlab+counter++) = tI->start.x;
        *(tMatlab+counter++) = tI->start.y;
        *(tMatlab+counter++) = tI->end.x;
        *(tMatlab+counter++) = tI->end.y;
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
    
    printf("Dims: [%d, %d, %d]\n", dims[0],dims[1],dims[2] );
    printf("Img: [%d, %d, %d,%d]\n", in->height,in->width,in->widthStep,in->imageSize );
    int idx;
    cvSaveImage("ftest.jpg",in);
    mexPrintf("First pixel: %d,%d,%d\n", (unsigned char)in->imageData[2],(unsigned char)in->imageData[1],(unsigned char)in->imageData[0]);
    
    
        for(int x=0 ; x<dims[1] ; x++){
          for(int y=0 ;y<dims[0] ;y++,op_ptr++){
              idx = in->nChannels*x+2+y*in->widthStep;
              //printf( "(x,y) = (%d,%d), idx = (%d), C(R): %c", x,y,idx, (float)in->imageData[3*x+2+y*in->widthStep] );
            *op_ptr = (unsigned char)in->imageData[idx] ;
          }
        }
        for(int x=0 ; x<dims[1] ; x++){
          for(int y=0 ;y<dims[0] ;y++,op_ptr++){
              idx = in->nChannels*x+1+y*in->widthStep;
              //printf( "(x,y) = (%d,%d), idx = (%d), C(R): %c", x,y,idx, (float)in->imageData[3*x+2+y*in->widthStep] );
            *op_ptr = (unsigned char)in->imageData[idx] ;
          }
        }
        for(int x=0 ; x<dims[1] ; x++){
          for(int y=0 ;y<dims[0] ;y++,op_ptr++){
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

    double* ml_tracks,*imgsize;
    unsigned char *ml_firstFrame;
    
    /* check for proper number of arguments */
    if(nrhs!=1) 
      mexErrMsgTxt("One input required.");
    else if(nlhs > 3) 
      mexErrMsgTxt("Too many output arguments.");

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
    string args[4]; 
    
    mexPrintf("Building args list\n");
    args[0] = "calling...";
    mexPrintf("%s, ", args[0].c_str( ));
    args[1] = filename;
    mexPrintf("%s, ", args[1].c_str( ));
    args[2] = "speed_vals";
    mexPrintf("%s, ", args[2].c_str( ));
    args[3] = "--nodisplay";
    mexPrintf("%s\n", args[3].c_str( ));
    mexPrintf("Args list built.\n");
    
    mainLoop( 2, args );
    
    
    
    plhs[0] = mxCreateDoubleMatrix(2,tracklets.size( )*2, mxREAL);
	ml_tracks = mxGetPr(plhs[0]);
    
    mwSize dims[3];
    dims[1] = firstFrame->width;
    dims[0] = firstFrame->height;
    dims[2] = 3;
    
    plhs[1] = mxCreateNumericArray(3,dims, mxUINT8_CLASS, mxREAL);
	ml_firstFrame = (unsigned char *) mxGetPr(plhs[1]);
    Ipl2MatlabImage( firstFrame, ml_firstFrame, dims);
    
    plhs[2] = mxCreateDoubleMatrix(1,2, mxREAL);
	imgsize = mxGetPr(plhs[2]);
    *imgsize = image->width;
    *(imgsize+1) = image->height;
    formatTrackletsForMatlab(&tracklets, ml_tracks );

    return;
}

int main( int argc, char** argv )
{
    string args[argc];
    
    for(int i=0;i<argc;i++) {
        args[i] = string(argv[i]);
    }
    
    return mainLoop( argc, args );
}

#ifdef _EiC
main(1,"lkdemo.c");
#endif
