function [region_trajectories, plane_regions] = multiplane_boundary_trajectory_split( trajectories, boundary_line_points )
    % Get the convex hull of the trajectories
    allPoints = [trajectories{:}];
    hull = convhull(allPoints(1,:), allPoints(2,:));
    hullPts = allPoints(:,hull);

    plane_regions = regions_from_boundaries( boundary_line_points, hullPts );
    
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