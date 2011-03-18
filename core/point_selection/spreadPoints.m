function spreadPoints(number_points, number_rands, C_im)


if nargin < 3,
    [~, ~, C_im] = make_test_data( 120, 50, 1, 0.05, number_points );
end
tic;
% Get Midpoints of lines
midpoints = (C_im(:,1:2:size(C_im,2)) + C_im(:,2:2:size(C_im,2))) ./ 2;
K = convhull(midpoints(1,:)',midpoints(2,:)');
hullPoints = midpoints(:, K);
fprintf('Getting midpoints takes %fseconds\n', toc );
% Get euclidean distance matrix
tic;
d_mat = squareform(pdist(hullPoints'));
fprintf('Getting distances takes %fseconds\n', toc );


[paths, distances] = pathfinder( size(hullPoints,2), number_rands, d_mat );

[max_dist, max_dist_idx] = max(distances);

maxpath = paths(max_dist_idx,:)

% Get original image indices
ids_A = (K(maxpath(1:max(size(maxpath))-1)) .* 2) -1
ids_B = (K(maxpath(1:max(size(maxpath))-1)) .* 2)
ids_full = sort([ids_A ; ids_B ]);

drawcoords(C_im);
scatter( midpoints(1,:), midpoints(2,:), 16, '*r')

plot( midpoints(1,K), midpoints(2,K), 'Color','magenta' );
plot(hullPoints(1,maxpath), hullPoints(2,maxpath))
title(sprintf('%d Points, %d Rands', number_points, number_rands));

