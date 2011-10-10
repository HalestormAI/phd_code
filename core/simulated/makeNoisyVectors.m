function [N,coords,im_coords] = makeNoisyVectors(theta, psi, d, alpha, noise, num )
% Create a set of noisy, simulated vectors.
%  Generates n from theta and psi, produces vectors on the plane then
%  produces image coordinates using alpha.
%
% INPUT:
%   theta      Angle of Elevation
%   psi        Yaw angle
%   d          Distance between plane and camera
%   alpha      Simulated image width
%   noise      Noise profile [type, type2, type3]
%   num        Number of vectors to produce
%
% OUTPUT:
%   N          Normal to the ground-plan e
%   coords     3D world coordinates
%   im_coords  2D image coordinates

    if length(noise) ~= 3,
        error('Invalid noise profile given.');
    end

    if nargin < 5,
        num = 8;
    end

    N = normalFromAngle( theta, psi );
    
    if noise(2) > 0,
        coords = make_noneven_angled_coords( N, d, 1, noise(2), num );
    else
        coords = make_angled_coords( N, d, 1, num );
    end
    if noise(1) > 0,
        [~,coords] = addType1Noise(coords, N, noise(1));
    end
    im_coords = wc2im( coords, alpha );
    
    if noise(3) > 0,
        mu_im = mean(speedDistFromCoords(im_coords));
        im_coords = add_coord_noise(im_coords,noise(3),mu_im,1);
    end
end