function [regions, boundaries] = hinged_reconstruction( root_hypothesis, angles, boundaries2d, region_parents, regions, draw )

if nargin < 6
    draw = 0;
end

angles
% Need initial orientation - use hypothesis for root region
    for r = 1:length(regions)
        regions(r).initial = cellfun(@(x) backproj_c(root_hypothesis(1),root_hypothesis(2),1,root_hypothesis(3), x), regions(r).traj,'un',0);
    end
    pcolours ='krbgmcy';
    % initialise 3d boundaries at initial orientation
    boundaries= cellfun(@(x) backproj_c(root_hypothesis(1),root_hypothesis(2),1,root_hypothesis(3), x), boundaries2d,'un',0);
    
    if draw
        drawtraj({regions.initial},'before bounds')
    end
    % Start with reference frame, get children
    for r = 1:length(regions)-1
        children = find_children( r, region_parents )
        for c=1:length(children)
            % for each child
            r_id = children(c);
            
            angle = angles(r);
            

            [regions(r_id).initial,newn,newd,regions(r_id).rpts] = rectify_region(regions(r_id), angle, boundaries{r}, root_hypothesis(3));
            
            if r_id <= length(boundaries)
%                 boundaries{r_id} = rectify_boundary( boundaries2d{r_id}, newn,newd,root_hypothesis(3));
                boundaries{r_id} = rectify_boundary( boundaries{r_id}, angle, boundaries{r});
            end       
            
        end
        if draw
            drawtraj({regions.initial},sprintf('parent %d',r));
            for b=1:length(boundaries)
                plot3(boundaries{b}(1,:), boundaries{b}(2,:), boundaries{b}(3,:),[pcolours(b+1),'--'], 'linewidth',2);
            end
        end
%         pause
        % once we've rectified all the regions, need to re-rectify boundary
        % lines so they fall in the correct place
    end

    
    function [rtraj,N,d,rpts] = rectify_region( region, angle, axis, alpha )
        % rotate trajectories for all child regions in AXIS by ANGLE
        
        traj = region.initial;
        imtraj = region.traj;
        rpts = axis_rot(axis,[traj{:}],angle);
        
        % Now get the plane parameters for these points
        [N,d] = planeFromPoints(rpts, length(rpts),'cross');
        
        % Finally, rectify using the discovered plane parameters
%         rtraj = cellfun(@(x) backproj_n(N,[d,alpha],x), imtraj, 'un', 0);

        rtraj = cellfun(@(x) axis_rot(axis,x,angle),traj,'un',0);
         
    end

%     function new_boundary = rectify_boundary( old_boundary, N, d, alpha)
    function new_boundary = rectify_boundary( old_boundary, angle, axis)
        % rotate the boundary point sitting on the old plane onto the new
        % rotated plane.
%         new_boundary = backproj_n(N,[d,alpha],old_boundary);
old_boundary
        new_boundary = axis_rot(axis,old_boundary,angle);
    end

    for r = 1:length(regions)
        regions(r).reconstructed = regions(r).initial;
    end
    regions = rmfield(regions,'initial');
end