function [actual_n,coords,im_coords,noisy_coords,noisy_im_coords] = make_test_data(theta, psi, d, alpha, num, noise )

    if nargin < 5,
        num = 8;
    end

    actual_n = normalFromAngle( theta, psi );
    
   % n = [nx; sin(deg2rad(theta)); cos(deg2rad(theta)) ];      % Create a normal
    
    coords = make_angled_coords( actual_n, d, l, num );     % Find world coordinates
    im_coords = image_coords_from_rw_and_plane( coords );   % Convert to image coordinates

    if nargin > 5 &&  noise > 0,
        noisy_coords = make_noneven_angled_coords( actual_n, d, l, noise, num );     % Find world coordinates
        noisy_im_coords = image_coords_from_rw_and_plane( noisy_coords );   % Convert to image coordinates
    end

end