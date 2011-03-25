function f = overlaycoords( im_coords, im )

    f = figure;
    imagesc( im );
    drawcoords( im_coords, '', 0, 'b' );
end