function make( filename )
    
    if strcmp(getenv('USER'),'ian')
        mydir = '/home/ian/PhD/repos/mex';
        libxml = '/usr/lib/i386-linux-gnu/libxml2.so';
    else
        mydir = '/home/csunix/sc06ijh/PhD/groundplane_matlab/mex';
        libxml = '/usr/lib64/libxml2.so';
    end
    
    pushd( mydir );
    
    mex( filename, 'mexHelper.cpp', 'Matrix.cpp', 'Trajectory.cpp', 'Point.cpp', 'camcal_pets/cameraModel.cpp', 'camcal_pets/xmlUtil.cpp', libxml, '-I/usr/include/libxml2', '-I./camcal_pets', '-g' );
    
    popd( );
    
end