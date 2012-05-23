project( Tracker )
find_package( OpenCV REQUIRED )

add_executable( Tracker Tracker )
target_link_libraries( Tracker ${OpenCV_LIBS} )
set(CMAKE_CXX_FLAGS "-O333")
