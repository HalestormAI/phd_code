function [imc,wcn] = addType1Noise( wc, N, level )
% Takes a set of world-coordinates and adds noise simulating the effect
% of tracking points on parallel planes above and below each other.
% INPUT:
%   wc      3xn matrix of world-coordinates, where n is even.
%   N       The normal to the original plane
%   level   The level of noise (sensible range: 0 < n_l < 1)
%
% OUTPUT:
%   imc     The 2xn matrix of noisy image coordinates
%   wcn     The 3xn matrix of noisy world coordinates

%% Generate a normally distributed, randomly sorted set of noise amounts
noise_dist = normrnd( 0, level, 1, size( wc,2 )/2 );

%% Iterate through each pair of points, offset from the plane
for i=1:2:size( wc,2 ),            
    randnum = rand(1);
    % 50% chance of above or below
    if randnum < 0.5,
        noise_pm = noise_dist( (i+1)/2 );
    else
        noise_pm = -noise_dist( (i+1)/2 );
    end
    
    % Move points in direction of the normal.
    C_offset(:,i:i+1) = bsxfun(@plus, wc(:,i:i+1), (noise_pm .* N) ) ;
end
wcn  = C_offset;
imc = image_coords_from_rw_and_plane( C_offset );