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
        pushd( strcat(getenv('HOME'),'/PhD/groundplane_matlab/mex/') );
        
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
            incdir = strcat( ...
                 ' -I/usr/not-backed-up/',vsn,'/modules/video/include')
        else
            incdir = strcat('-I/usr/not-backed-up/',vsn,'/include/opencv')
        end
        libdir = strcat('-L/usr/not-backed-up/',vsn,'/lib')

        mex( fn, incdir, libdir, '-lcv', '-lcvaux', '-lcxcore', '-lhighgui', '-lstdc++', DEBUG);
    end
end
