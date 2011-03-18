function [ ids_full ] = monteCarloPaths( C_im, NUM_RANDOMS, NUM_PATHS_MONTE, ALPHA, DEBUG )
% Finds a "good" (high distance, but non-optimal) path from a set of image
% points
% 
% Input:
%    C_im           A set of image coords
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
    NUM_PATHS_MONTE = 3;
end
if nargin < 4,
    ALPHA = 10;
end
if nargin < 5,
    DEBUG = 0;
end

NUM_HULLS = 2;

ALPHA_START = ALPHA;

% Get midpoints and their hull
midpoints = (C_im(:,1:2:size(C_im,2)) + C_im(:,2:2:size(C_im,2))) ./ 2;

extraPoints = cell( 1,NUM_HULLS );

try
for i=1:NUM_HULLS,
        % Put hullpoints in terms of midpoints
        nonConvexMidpointIds = setxor(1:size(midpoints,2), cell2mat(extraPoints) );
        nonConvexMidpoints = midpoints( :, nonConvexMidpointIds );

        % Now find hull of remaining points (add more points for selection)
    %     convhull(nonConvexMidpoints(1,:)',nonConvexMidpoints(2,:)')
        pts=nonConvexMidpointIds( convhull(nonConvexMidpoints(1,:)',nonConvexMidpoints(2,:)') );
        extraPoints{i} = pts;

    end
catch err,
    disp(err.identifier);
    rethrow(err);
end
ids = cell2mat(extraPoints);
hulls = midpoints(:,ids);

% Debug drawing methods
if DEBUG,
    figure,title(sprintf('Hulls %d',i));drawcoords(C_im,'',0,'b');
    %plot( midpoints(1,:),midpoints(2,:),'r', 'LineWidth', 3 )
    scatter( hulls(1,:),hulls(2,:),'g', 'LineWidth', 3 )
end


tic;
% Distance matrix for pathfinder
d_mat = squareform(pdist(hulls'));
[paths, distance_sums, distances] = pathfinder( size(hulls,2), NUM_RANDOMS, d_mat );

% This is where we make our monte-carlo choice
% Pick 3 numbers, then chose the max path from those
path_ids = randi( size(paths,1), 1, NUM_PATHS_MONTE );


[ ~ , sorted_ids ] = sort(distance_sums(path_ids),'descend');

% Now have a sorted random selection and can put in original context:
%   e.g.  paths(path_ids(sorted_ids),:)

%distance_sums(path_ids)
found_one = 0;
attempts = 0;
while ~found_one,
    for i = 1:NUM_PATHS_MONTE,
        chosenPath_id = path_ids(sorted_ids(i));
        chosenPath = paths(chosenPath_id,:);
        % Check if path is suitable:
        %   D_i > M_d +/- a*S_d, for all distances
        m_d = mean(distances(chosenPath_id,:));
        s_d = std(distances(chosenPath_id,:));
        is_ok = abs( distances(chosenPath_id,:)  - m_d ) < ALPHA*s_d;
        if sum(is_ok) == NUM_RANDOMS,
            found_one = 1;
            break;
        elseif DEBUG
            % Debug: Draw bad paths
            used_coords = hulls(:,chosenPath);
           % plot( used_coords(1,:), used_coords(2,:), 'r', 'LineWidth', 2  )
        end
    end

    if found_one ~= 1,
        if attempts < 20000,
            % Increase leniency and try again
           % fprintf('Increasing leniency from %f to %f\n', ALPHA, ALPHA+ALPHA_INC);
            ALPHA = ALPHA + ALPHA_INC;
        else
            % reset alpha and attempts
            ALPHA = ALPHA_START;
            attempts = 0;
            % Build a new set of random paths and sort
            path_ids = randi( size(paths,1), 1, NUM_PATHS_MONTE );
            [ ~ , sorted_ids ] = sort(distance_sums(path_ids),'descend');
        end
        attempts = attempts + 1;
            
    end
end


% Now put in terms of full image coords (not midpoints)
ids_A = (ids(chosenPath(1:end-1)) .* 2) -1;
ids_B = (ids(chosenPath(1:end-1)) .* 2);

ids_full = sort([ids_A , ids_B ]);


% Debug drawing methods
if DEBUG,
     used_coords = hulls(:,chosenPath);
     plot( used_coords(1,:), used_coords(2,:), 'g', 'LineWidth', 3  )
end