function [current_polygons,node_parents] = regions_from_boundaries( boundary_line_points, hullPts )
% REGIONS_FROM_BOUNDARIES Takes the points around the imaged trajectories'
% convex hull and the endpoints of the boundary lines, then cuts the convex
% hull into individual polygons for each region.
%
% Usage:
%   CP = REGIONS_FROM_BOUNDARIES( L, H )
%       L = Boundary line endpoints
%       H = Convex hull of image trajectories
%      CP = Cx1 cell containing cut polygons
%
%   [...,NP] = REGIONS_FROM_BOUNDARIES(...)
%       NP = 1xC vector containing ids of parent polygons (i.e. which
%            planes are attached to one another).
%       
% See Also: MULTIPLANE_BOUNDARY_TRAJECTORY_SPLIT

    node_parents = [0];
    
    img_mm = minmax(hullPts);
    current_polygons{1} = hullPts';
    for l=1:length(boundary_line_points)
        %        ext_boundary_points = line_to_boundaries( boundary_line_points{l}, img_mm );
        %        [xi,yi] = polyxpoly( ext_boundary_points(1,:), ext_boundary_points(2,:),hullPts(1,:), hullPts(2,:));

        use_poly =[];
        found = 0;
        if length(current_polygons) > 1
            % work out which polygon this line crosses.
            ext_boundary_points = line_to_boundaries( boundary_line_points{l}, img_mm );
%                         figure;
            for p=1:length(current_polygons)
%                                 plot(hullPts(1,:),hullPts(2,:),'b-')
%                                 hold on;
%                                 plot(current_polygons{p}(:,1),current_polygons{p}(:,2),'m-')
                [xi,yi] = polyxpoly( ext_boundary_points(1,:), ext_boundary_points(2,:),current_polygons{p}(:,1), current_polygons{p}(:,2));
%                                 plot(ext_boundary_points(1,:), ext_boundary_points(2,:),'y-','LineWidth',3);
%                                 plot(boundary_line_points{l}(1,:), boundary_line_points{l}(2,:),'g-','LineWidth',3);
%                                 hold off
%                                 pause;
                if length(xi) >= 2
                    use_poly(end+1) = p;
                    found = 1;
%                     break;
                end
            end
        else
            use_poly = 1;
            found = 1;
        end
        use_poly
%                                 hold on;
%         for q = 1:length(current_polygons)
%             
%             plot(current_polygons{q}(:,1),current_polygons{q}(:,2),'r--')
%         end
        if found
            use_poly = use_poly(1);
            use_pts = current_polygons{use_poly};
%             figure;
%             subplot(2,1,1);
            PP_top = cutpolygon(use_pts,boundary_line_points{l}','B'); % TODO: Checks for line angle (T/B vs R/L)
%             subplot(2,1,2);
            PP_bottom = cutpolygon(use_pts,boundary_line_points{l}','T');
%             pause
%             close;
            current_polygons{use_poly} = PP_top;
            current_polygons{end+1} = PP_bottom;
            node_parents(length(current_polygons)) = use_poly;
        end
    end
end