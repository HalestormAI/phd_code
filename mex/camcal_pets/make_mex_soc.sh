#!/bin/bash

echo "Making xmlUtil.o";
g++ -c xmlUtil.cpp -o xmlUtil.o -I. -I/usr/include/libxml2
echo "Making cameraModel.o";
g++ -c cameraModel.cpp -o cameraModel.o -I. -I/usr/include/libxml2
echo "Making PETSCalibrationParameters.o";
g++ -c PETSCalibrationParameters.cpp -o PETSCalibrationParameters.o -I. -I/usr/include/libxml2  -I /usr/local/matlab-R2011a/extern/include/
echo "Linking";
mex PETSCalibrationParameters.o xmlUtil.o cameraModel.o -I/usr/include/libxml2/
