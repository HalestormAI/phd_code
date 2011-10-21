function makeCpp( fn, DBG )

    if nargin < 2 || ~DBG,
        DEBUG = '';
    else
        DEBUG = ' -g';
    end

    try
        domex(fn);
    catch err,
        pushd( strcat(getenv('HOME'),'/PhD/groundplane_matlab/mex/') );
        
        try
            domex(fn);
            popd();
        catch err2,
            popd();
            rethrow(err2);
        end
        
    end
    
    function domex( fn )
        mex( fn, '-I/usr/not-backed-up/OpenCV-2.1.0/include/opencv', ...
             '-L/usr/not-backed-up/OpenCV-2.1.0/lib', '-lcv', ...
             '-lcvaux', '-lcxcore', '-lhighgui', '-lstdc++', DEBUG);
    end
end