#include "Tracklet.h"

IJH::Tracklet::Tracklet( CvPoint *s, CvPoint *e, int f ) {
    start = *s;
    end = *e;
    creationFrame = f;

    float dx = abs( s->x - e->x );
    float dy = abs( s->y - e->y );

    speed = sqrt( dx*dx + dy*dy );
    angle = -1;
    
    getPassPoints( );
//  angle = (int)getAngle( );
}


IJH::Tracklet::Tracklet( ) {
    start = cvPoint( 0,0 );
    end   = cvPoint( 0,0 );
    speed = 0;
}

float IJH::Tracklet::getAngle( Tracklet *up ) {

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

    double a = IJH::radToDeg(acos(cosAlpha));

    // Hack for dot product only handling 0 < x < 180
    if (start.x > end.x) {
      a+=180;
    }

    // Reverse so dir[0] = up
    a+=180;

    // Ensure 0 < a < 360
    a = int(a)%360;

    if (isnan(a) ) {
        std::cout << "Angle IsNAN" << std::endl;
        return 0;
    } else {
        angle = a;
        return angle;
    }

}

void IJH::Tracklet::draw(IplImage *im, CvScalar *colour, int width /*= 1*/) {
    //CvScalar colour = cvScalar(0, g, 0);

    if (width > 0)
        cvLine(im, start, end, *colour, width);

    // add circle to end point
    //cvCircle(im, nd, 3, *colour, -1, CV_AA, 0);
}

CvScalar IJH::Tracklet::getColour( int angle ) {

    CvScalar col;

    int r = (int) 255 * getColourWeight( (angle) % 360, 0);
    int g = (int) 255 * getColourWeight( (angle+120) % 360, 0);
    int b = (int) 255 * getColourWeight( (angle+240) % 360, 0);

    col = cvScalar( b, g, r );

    return col;

}        


int IJH::Tracklet::getPassPoints() {
    // Tracking point to check location on line.

    CvPoint whereWeAre;
    whereWeAre = start;
    int i = start.x - end.x;
    int j = start.y - end.y;

    int numPoints = bresenhamsAlgorithm(&whereWeAre, end,
            passPoints, i, j);

    return numPoints;
    //printf("Done bres");
}
