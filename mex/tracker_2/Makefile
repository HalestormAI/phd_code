# Compile and link flags
CXX          = mex
CFLAGS       = -Wall -g

# Compilation (add flags as needed)
#CXXFLAGS    +=  -I/usr/not-backed-up/OpenCV-2.3.1/modules/core/include -I/usr/not-backed-up/OpenCV-2.3.1/modules/features2d/include -I/usr/not-backed-up/OpenCV-2.3.1/modules/video/include -I/usr/not-backed-up/OpenCV-2.3.1/modules/imgproc/include -I/usr/not-backed-up/OpenCV-2.3.1/modules/highgui/include -I/usr/not-backed-up/OpenCV-2.3.1/modules/flann/include #`pkg-config opencv --cflags`
CXXFLAGS    += -I/usr/local/MATLAB/R2011b/extern/include

# Linking (add flags as needed)
#LDFLAGS     += -L/usr/not-backed-up/OpenCV-2.3.1/build/lib
#`pkg-config opencv --libs`

LDFLAGS     += -lopencv_core -lopencv_imgproc -lopencv_video -lopencv_features2d -lopencv_highgui

# Name your target executables here
all         = Tracker

# Default target is the first one - so we will have it make everything :-)
all: $(all)

# Program dependencies (.o files will be compiles by implicit rules)
