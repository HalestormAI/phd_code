function [regions,remaining] = generateRandomRegions( im_coords, im1, NUM_REGIONS, R )
% Find n random regions in a set of im_coords
global colours;

if nargin < 3,
    NUM_REGIONS = 6;
end

REGION_SIZE = max(size(im1))/R;
regions = cell(NUM_REGIONS,1);
centreids = zeros(NUM_REGIONS,1);
remaining = im_coords;

for i=1:NUM_REGIONS,
    % Generate midpoints from remaining vectors
    midpoints = coord2midpt( remaining );
    
    % Generate pairwise distances between midpoints
    distances = squareform(pdist(midpoints'));
    
    % Select random vector
    centreids(i) = randi(length(midpoints));
    
    % Pick all vectors with midpoints within REGION_SIZE
    near = mpid2cid( find(distances(centreids(i),:) < REGION_SIZE) );
    
    % Add to region cell
    regions{i} = remaining(:,near);
    
    % Remove from set
    remaining(:,near) = [];
end

drawcoords(remaining);
for i=1:NUM_REGIONS,
    drawcoords(regions{i},'',0,colours(i));
end