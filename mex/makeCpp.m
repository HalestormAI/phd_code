function makeCpp( fn, DBG, vsn, ocvver )

    if nargin < 2 || ~DBG,
        DEBUG = ' ';
    else
        DEBUG = ' -g';
    end

    if nargin < 3,
        vsn = 'Opencv-2.1.0';
    end
    if nargin < 4,
        ocvver = 2;
    end

    try
        domex(fn, vsn, ocvver);
    catch err,
        pushd( strcat(getenv('HOME'),'/PhD/repos/mex/') );
        
        try
            domex(fn, vsn, ocvver);
            popd();
        catch err2,
            popd();
            rethrow(err2);
        end
        
    end
    
    function domex( fn, vsn, ocvver )
        if ocvver == 2
%             incdir = strcat( ...
%                  ' -I/usr/not-backed-up/',vsn,'/modules/core/include');
%             incdir = strcat( incdir, ...
%                  ' -I/usr/not-backed-up/',vsn,'/modules/features2d/include');
%             incdir = strcat( incdir, ...
%                  ' -I/usr/not-backed-up/',vsn,'/modules/video/include');
%             incdir = strcat( incdir, ...
%                  ' -I/usr/not-backed-up/',vsn,'/modules/imgproc/include');
%             incdir = strcat( incdir, ...
%                  ' -I/usr/not-backed-up/',vsn,'/modules/highgui/include')
%             libdir = strcat('-L/usr/not-backed-up/',vsn,'/build/lib')

        incdir = '-I/usr/not-backed-up/OpenCV-2.3.1/modules/core/include -I/usr/not-backed-up/OpenCV-2.3.1/modules/features2d/include -I/usr/not-backed-up/OpenCV-2.3.1/modules/video/include -I/usr/not-backed-up/OpenCV-2.3.1/modules/img    proc/include -I/usr/not-backed-up/OpenCV-2.3.1/modules/highgui/include -I/usr/not-backed-up/OpenCV-2.3.1/modules/flann/include';
        libdir = '-L/usr/not-backed-up/OpenCV-2.3.1/build/lib';
        else
            incdir = strcat('-I/usr/not-backed-up/',vsn,'/include/opencv')
        libdir = strcat('-L/usr/not-backed-up/',vsn,'/lib')
        end
incdir
        mex( fn, incdir, libdir, '-lopencv_core', '-lopencv_imgproc', '-lopencv_video', '-lopencv_features2d', '-lopencv_highgui','-lboost_system','-lboost_filesystem', DEBUG);
    end
end
