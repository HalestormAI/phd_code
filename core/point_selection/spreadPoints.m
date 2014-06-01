function [chosen_coords, areas] = spreadPoints(number_points, number_rands, C_im, frame)

if nargin < 3,
    [~, ~, C_im] = make_test_data( 120, 50, 1, 0.05, number_points );
end

input_set = [1 50 250 400 800 1200 1600 2400 3200];
tic;
% Get Midpoints of lines
midpoints = (C_im(:,1:2:size(C_im,2)) + C_im(:,2:2:size(C_im,2))) ./ 2;
K1 = convhull(midpoints(1,:)',midpoints(2,:)');
mp_idx = 1:length(midpoints);
mp_idx(K1) = [];

midpoints2 = midpoints;
midpoints2(:,K1) = [];


K2 = convhull(midpoints2(1,:)',midpoints2(2,:)');
K2_idx = mp_idx(K2);

K = [K1;K2_idx'];

hullPoints = midpoints(:, K);

fprintf('Getting midpoints takes %fseconds\n', toc );
% Get euclidean distance matrix
% tic;
% d_mat = squareform(pdist(hullPoints'));
% fprintf('Getting distances takes %fseconds\n', toc );


% [paths, distances] = pathfinder( size(hullPoints,2), number_rands, d_mat );
% [max_dist, max_dist_idx] = max(distances);
% maxpath = paths(max_dist_idx,:)

[output_paths, areas] = max_poly_areas(hullPoints, 4);

chosen_coords = cell(length(input_set),1);
for pp = 1:length( input_set )
    maxpath = output_paths(input_set(pp),:);
    chosen_coords{pp} = hullPoints(:,maxpath);
    figure;
    imshow(frame,'border','tight');
    hold on;
%     drawcoords_fast(C_im,'',0,'w');
    % scatter( midpoints(1,:), midpoints(2,:), 16, '*r')

    plot( midpoints(1,K1), midpoints(2,K1), 'ms--','LineWidth',2,'markerfacecolor','m' );
    K1_coords = C_im(:, mpid2cid(K1));
    drawcoords_fast(K1_coords,'',0,'m');
    plot( midpoints(1,K2_idx), midpoints(2,K2_idx), 'gs--','LineWidth',2,'markerfacecolor','m' );
    K2_coords = C_im(:, mpid2cid(K2_idx));
    drawcoords_fast(K2_coords,'',0,'g');

    plot(hullPoints(1,maxpath), hullPoints(2,maxpath),'bo-','LineWidth',2,'MarkerFaceColor','b')
end

% Get original image indices
% ids_A = (K(maxpath(1:max(size(maxpath))-1)) .* 2) -1;
% ids_B = (K(maxpath(1:max(size(maxpath))-1)) .* 2);
% ids_full = sort([ids_A ; ids_B ]);



    function [largest_path, areas] = max_poly_areas( pts, num_rand )
        polys = combnk(1:size(pts,2), num_rand);
        polys(:,num_rand+1) = polys(:,1);
        
        areas = Inf*ones(size(polys,1),1);
        parfor i=1:size(polys,1)
%             tic;
            ids = polys(i,:);
            areas(i) = polyarea(pts(1,ids),pts(2,ids));
%             fprintf('\tFinding area %d of %d - %fseconds\n', i, size(polys,1), toc );
        end
        [~,sortid] = sort(areas,'descend');
%         maxid = sortid(end-1600);
        largest_path = polys(sortid,:);
    end

end