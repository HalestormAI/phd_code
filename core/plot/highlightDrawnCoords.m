function highlightDrawnCoords( c, c_i_n, i_used, idx )
%
% Input:
%   c       Correct 3D world coords *
%   c_i_n   Estimated image coords *
%   i_used  Used coord indices *
%   idx     Iteration number
%
%   (* = for all iterations)
%


c_i = image_coords_from_rw_and_plane( c(:,:,idx));

drawcoords( c_i_n(:,:, idx), '' ,1,'b' )
drawcoords( c_i, '' ,0,'r' )
cin = rescaleImageToPx( c_i_n(:, i_used(idx,:), idx) );
scatter( cin(1,:),cin(2,:),20, 'g')