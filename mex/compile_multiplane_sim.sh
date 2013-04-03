#!/bin/bash

INCLUDES="-I/usr/include/libxml2 -I./camcal_pets"
SOURCES="Matrix.cpp Point.cpp Plane.cpp Trajectory.cpp Line.cpp functions.cpp SimTrajectory.cpp camcal_pets/cameraModel.cpp camcal_pets/xmlUtil.cpp /usr/lib/i386-linux-gnu/libxml2.so"

CFLAGS="-g"

mex $1 $INCLUDES $SOURCE $CFLAGS
