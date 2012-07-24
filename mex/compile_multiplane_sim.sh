#!/bin/bash

mex multiplane_add_trajectories.cpp Matrix.cpp Point.cpp Plane.cpp Trajectory.cpp Line.cpp functions.cpp SimTrajectory.cpp camcal_pets/cameraModel.cpp camcal_pets/xmlUtil.cpp /usr/lib/i386-linux-gnu/libxml2.so -I/usr/include/libxml2 -I./camcal_pets -g
