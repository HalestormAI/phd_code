function showPathConnections( ID, im_usable, im1 );

    overlayCoords(im_usable{ID},im1)
    scatter(im_usable{ID}(1,1),im_usable{ID}(2,1),24,'g')
    drawcoords(im_usable{ID}(:,2:end-1),'',0,'r')
