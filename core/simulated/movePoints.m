function [newpos, newdirections] = movePoints(current, directions, velocities, planes, timestep)
    if nargin < 5,
        timestep = 1;
    end
    
    newpos = cell(size(current));
    newdirections = directions;
    for i=1:length(current),
        try
            cplane = getPlaneFromLocation( current{i}, planes );
            travel = directions{i}*velocities{i}*timestep;
            npos = current{i}+travel;
            nplane = getPlaneFromLocation( npos, planes );
            % If we've changed planes, need to find the position at plane
            % change as a proportion of timestep. Then change direction and 
            % move the remainder of time step on the new plane.
            if cplane ~= nplane,

                fprintf('%d: CHANGED PLANES\n',i);
                % Find line of intersection between planes
                intersection = intersect(planes(cplane).points',planes(nplane).points','rows')';
                if isempty(intersection),
                    error('Planes do not intersect');
                end
                % Get distance travelled to plane border.
                x0 = current{i};
                x1 = intersection(:,1);
                x2 = intersection(:,2);
                d  = norm(cross(x2-x1,x0-x1))/norm(x2-x1);

                edgePos = x0 + d*directions{i};
                
                % Get d as proportion of total distance
                t = d/velocities{i};
                t_rem = timestep-t;

                % Find new direction from plane points
                newdirections{i} = (planes(nplane).points(:,4) - planes(nplane).points(:,1));
                
                % Find previous rotation and put onto new plane direction
                origdrn = (planes(cplane).points(:,4) - planes(cplane).points(:,1));
                rot = makehgtform('zrotate', ...
                      acos(dot(origdrn, directions{i}) / ...
                      (norm(origdrn)*norm(directions{i}))));
                rottoz = makehgtform('xrotate',anglesFromN(planes(nplane).n));
                newdrn = rottoz'*rot*rottoz*makeHomogenous(newdirections{i} ./ norm(newdirections{i}));
                newdirections{i} = newdrn(1:3);
                oldtravel = travel;

                travel = newdirections{i}*velocities{i}*t_rem;
                npos = edgePos+travel;
            end
        catch err,
            if strcmp(err.identifier,'IJH:MULTIPLANE:OFFPLANE'),
                npos = current{i};
            end
        end
        newpos{i} = npos;
    end
end