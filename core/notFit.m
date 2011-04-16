function doesntfit = notFit( im_coords, H, plane, alpha )
% Performs a 2-sample KS-test on an actual and estimated plane
%  Determines whether two sets of vectors have similar distributions. If
%  they do, returns 0, if not returns 1.
%
%  INPUT:
%   im_coords   A set of 2D image coordinates
%   H           The ground-truth, either as a 3x3 plane-plane homography or
%               a 1x5 iteration vector.
%   plane       The estimated plane in structure format
%   alpha       The significance level of the KS-Test
%
%  OUTPUT:
%   doesntfit   False if the distributions match, false otherwise

if numel(H) == 5,
    % H is actually a NORMAL
    rw_1 = find_real_world_points( im_coords, iter2plane(H) );
else
    rw_1 = H*makeHomogenous( im_coords );
end

im_1 = find_real_world_points( im_coords, plane );

rw_spds  = speedDistFromCoords( rw_1 );
rw_spds = round2(rw_spds ./ mean(rw_spds), 0.00001);
im_spds  = speedDistFromCoords( im_1 );
im_spds = round2(im_spds ./ mean(im_spds), 0.00001);
try
    doesntfit = kstest2( rw_spds, im_spds, alpha );
catch err,
    if strcmp(err.identifier,'MATLAB:histc:InvalidInput'),
        doesntfit = 1;
    else
        rethrow(err);
    end
end
    
