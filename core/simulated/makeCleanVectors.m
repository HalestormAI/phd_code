function [N,coords,im_coords] = makeCleanVectors(theta, psi, d, alpha, num )
% Create a set of clean, simulated vectors.
%  Generates n from theta and psi, produces vectors on the plane then
%  produces image coordinates using alpha.
%
% INPUT:
%   theta      Angle of Elevation
%   psi        Yaw angle
%   d          Distance between plane and camera
%   alpha      Simulated image width
%   num        Number of vectors to produce
%
% OUTPUT:
%   N          Normal to the ground-plane
%   coords     3D world coordinates
%   im_coords  2D image coordinates

    if nargin < 5,
        num = 8;
    end

    N = normalFromAngle( theta, psi );
    
    coords = make_angled_coords( N, d, 1, num );     % Find world coordinates
    im_coords = wc2im( coords, alpha );   % Convert to image coordinates
end