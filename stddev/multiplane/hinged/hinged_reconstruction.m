function [regions, boundaries] = hinged_reconstruction( root_hypothesis, angles, boundaries2d, region_parents, regions )

% Need initial orientation - use hypothesis for root region
    for r = 1:length(regions)
        regions(r).initial = cellfun(@(x) backproj_c(root_hypothesis(1),root_hypothesis(2),1,root_hypothesis(3), x), regions(r).traj,'un',0);
    end
    
    % initialise 3d boundaries at initial orientation
    boundaries= cellfun(@(x) backproj_c(root_hypothesis(1),root_hypothesis(2),1,root_hypothesis(3), x), boundaries2d,'un',0);
    
%     drawtraj({regions.initial})

    % Start with reference frame, get children
    for r = 1:length(regions)-1
        children = find_children( r, region_parents );
        for c=1:length(children)
            % for each child
            r_id = children(c);
            
            angle = angles(r);
            

            [regions(r_id).initial,newn,newd] = rectify_region(regions(r_id), angle, boundaries{r}, root_hypothesis(3));
            
            if r_id <= length(boundaries)
                boundaries{r_id} = rectify_boundary( boundaries2d{r_id}, newn,newd,root_hypothesis(3));
            end       
            
        end
        
        % once we've rectified all the regions, need to re-rectify boundary
        % lines so they fall in the correct place
    end

    
    function [rtraj,N,d] = rectify_region( region, angle, axis, alpha )
        % rotate trajectories for all child regions in AXIS by ANGLE
        
        traj = region.initial;
        imtraj = region.traj;
        rpts = axis_rot(axis,[traj{:}],angle);
        [N,d] = planeFromPoints(rpts, length(rpts),'cross');
        rtraj = cellfun(@(x) backproj_n(N,[d,alpha],x), imtraj, 'un', 0);
    end

    function new_boundary = rectify_boundary( old_boundary, N, d, alpha)
        % rotate the boundary point sitting on the old plane onto the new
        % rotated plane.
        new_boundary = backproj_n(N,[d,alpha],old_boundary);
    end

    for r = 1:length(regions)
        regions(r).reconstructed = regions(r).initial;
    end
    regions = rmfield(regions,'initial');
end