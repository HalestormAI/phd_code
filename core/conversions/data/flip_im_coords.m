function im_flip = flip_im_coords( im_coords, im )

    im_flip = [im_coords(1,:); size(im,1) - im_coords(2,:)];

end