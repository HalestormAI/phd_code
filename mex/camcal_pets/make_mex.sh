#!/bin/bash

rm PETSCalibrationParameters.mexglx

echo "Making xmlUtil.o";
g++ -c xmlUtil.cpp -o xmlUtil.o -I. -I/usr/include/libxml2
echo "Making cameraModel.o";
g++ -c cameraModel.cpp -o cameraModel.o -I. -I/usr/include/libxml2
echo "Making PETSCalibrationParameters.o";
g++ -c PETSCalibrationParameters.cpp -o PETSCalibrationParameters.o -I. -I/usr/include/libxml2  -I/usr/local/MATLAB/R2011b/extern/include/
echo "Linking";
mex PETSCalibrationParameters.o xmlUtil.o cameraModel.o /usr/lib/i386-linux-gnu/libxml2.so -I/usr/include/libxml2/
