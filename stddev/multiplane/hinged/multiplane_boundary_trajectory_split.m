function [region_trajectories, plane_regions, plane_graph] = multiplane_boundary_trajectory_split( trajectories, boundary_line_points, plane_regions, plane_graph )
% MULTIPLANE_BOUNDARY_TRAJECTORY_SPLIT Generate new regions from the global
% trajectory set based on boundary lines given as end points.
%
% Usage:
%   RT = MULTIPLANE_BOUNDARY_TRAJECTORY_SPLIT( T, L )
%       T = Tx1 Cell array of image trajectories
%       L = (|P|-1)x1 cell of 2x2 boundary point matrices
%      RT = Rx1 cell of cells, where each outer cell contains the
%           trajectories for region.
%
%   [RT,PR] = MULTIPLANE_BOUNDARY_TRAJECTORY_SPLIT( ... )
%      PR = Px1 cell of polygons representing each plane boundary
%
%   [RT,PR,PG] = MULTIPLANE_BOUNDARY_TRAJECTORY_SPLIT( ... )
%      PG = 1xP vector containing ids of parent polygons (i.e. which
%            planes are attached to one another).
%
% Get the convex hull of the trajectories
allPoints = [trajectories{:}];
hull = convhull(allPoints(1,:), allPoints(2,:));
hullPts = allPoints(:,hull);
if nargin < 3 || isempty(plane_regions)
    if nargin < 4
        warning('Plane graph wasn''nt provided, attempting to calculate regions and graph automatically');
    end
    [plane_regions,plane_graph] = regions_from_boundaries( boundary_line_points, hullPts );
end

region_trajectories = cell(length(plane_regions),1);
for p=1:length(plane_regions)
    % Allocate some space for trajectories for the same of speed.
    % We'll tidy up spare space later.
    region_trajectories{p} = cell( 10*length(trajectories),1);
    curid= 1;
    for t=1:length(trajectories)
        invec = inpolygon(trajectories{t}(1,:), trajectories{t}(2,:),plane_regions{p}(:,1),plane_regions{p}(:,2));
        
        [splits, splitIds] = SplitVec( invec, 'equal','split','index' );
        
        for s=1:length(splits)
            if any(splits{s}) % Check this is a group that is "in" the region
                region_trajectories{p}{curid} = trajectories{t}(:,splitIds{s});
                curid = curid + 1;
            end
        end
    end
    
    % Tidy up the excess allocated memory.
    region_trajectories{p}(curid:end) = [];
    
end
end