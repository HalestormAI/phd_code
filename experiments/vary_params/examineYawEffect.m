function M = examineYawEffect( )


   nxs = 0:0.0005:0.75
   
   
   fnum = 1;
   for nx=nxs,
    try
        [N_orig, C, C_im] = make_test_data( 120, 50, 1, nx, 100 );
   
   
        planeTest = createPlane( C(:,1)', C(:,2)', C(:,3)' )
        f=figure('Visible','off'),
        drawcoords3( C, sprintf('Yaw for nx=%f', nx), 0, 'm' );
        drawPlane3d( planeTest );   
        view( -45, 4)
        M(fnum) = getframe;
        fnum = fnum+1;
        close( f );
    catch ...
            disp('Broke on this')
    end
    
   end
   
   