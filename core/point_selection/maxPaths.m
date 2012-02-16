function [ids_full] = maxPaths( im_coords, NUM_RANDOMS,ALPHA,DEBUG )
% Finds an optimal path from a set of image points
% 
% Input:
%    im_coords           A set of image coords
%    NUM_RANDOMS    Number of points to make up the path (default = 3)
%
% Output:
%    ids_full       The set of vector endpoints on the chosen path
%


ALPHA_INC = 0.5;
if nargin < 2,
    NUM_RANDOMS = 3;
end
if nargin < 3,
    ALPHA = 10;
end

if nargin < 4,
    DEBUG = 0;
end


  % get midpoints of lines
midpoints = (im_coords(:,1:2:size(im_coords,2)) + im_coords(:,2:2:size(im_coords,2))) ./ 2;

% get convex hull of midpoints
convexHull = convhull(midpoints(1,:)',midpoints(2,:)');
hullPoints = midpoints(:, convexHull);

% Debug drawing methods
if DEBUG,
    drawcoords( im_coords );
    %scatter( midpoints(1,:), midpoints(2,:), 16, '*r')

    hold on

    plot( midpoints(1,convexHull), midpoints(2,convexHull) );
end

% get inter-point distances
d_mat = squareform(pdist(hullPoints'));

% then find all paths involving points on hull
%[paths, distances] = pathfinder( size(hullPoints,2), NUM_RANDOMS, d_mat );

[paths, distance_sums, distances] = pathfinder( size(hullPoints,2), NUM_RANDOMS, d_mat );

[ ~ , sorted_ids ] = sort(distance_sums,'descend');
distances_sorted = distances(sorted_ids);

found_one = 0;
while ~found_one,
    for i=1:size(distances_sorted,1),
        chosenPath_id = sorted_ids(i);
        chosenPath = paths(chosenPath_id,:);
        distances(chosenPath_id,:);
        m_d = mean(distances(chosenPath_id,:));
        s_d = std(distances(chosenPath_id,:));
%         [abs( distances(chosenPath_id,:)  - m_d )  ALPHA*s_d ]
        is_ok = abs( distances(chosenPath_id,:)  - m_d ) < ALPHA*s_d;
        if sum(is_ok) == NUM_RANDOMS,
            found_one = 1;
            break;
        elseif DEBUG
            % Debug: Draw bad paths
            used_coords = hullPoints(:,chosenPath);
            plot( used_coords(1,:), used_coords(2,:), 'r', 'LineWidth', 2  )
        end
    end
    if found_one ~= 1,
        % Increase leniency and try again
      %  fprintf('Increading leniency from %f to %f\n', ALPHA, ALPHA+ALPHA_INC);
        ALPHA = ALPHA + ALPHA_INC;
        if ALPHA > 10
            ALPHA_INC = 5;
        end
        if ALPHA > 200
            used_coords = hullPoints(:,chosenPath);
            plot( used_coords(1,:), used_coords(2,:), 'r', 'LineWidth', 2  )
            error('This is never gonna work');
        end
            
    end
end

% pick suitable path of greatest distance
[~, max_dist_idx] = max(distance_sums);
maxpath = paths(max_dist_idx,:);
ids_A = (convexHull(maxpath(1:end-1)) .* 2) -1;
ids_B = (convexHull(maxpath(1:end-1)) .* 2);
ids_full = sort([ids_A ; ids_B ]);

% Debug drawing methods
if DEBUG,
    used_coords = hullPoints(:,chosenPath);
    plot( used_coords(1,:), used_coords(2,:), 'g', 'LineWidth', 4  )
end