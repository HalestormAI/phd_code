function cost = costFn( vec, nMids, nPlanes, plane )
% Cost function for alpha-expansion/alpha-beta swap
%
% INPUT:
%   vec       The vector in question (2x2 matrix where each endpoint is a
%             2x1 vector)
%   nMids     Neighbour midpoints
%   nPlanes   Neighbour plane labelings
%   plane     Plane assigned to input vector
%
% OUTPUT:
%   cost      Cost value (sim / im_dist) + E_d

    if ~isnumeric(plane) || ~isequal( size(plane), [1,5] ),
        error('Plane should be a 1x5 vector [d, n'', alpha]');
    end
    
    E_d = dist_eqn( plane, vec );
    
    similarities = ( cellfun( @(x) s(plane,x), ...
                                      num2cell(nPlanes,2)...
                                     ) ...
                           )';
    distances = ( cellfun( @(x) d(coord2midpt(vec),x), ...
                                      num2cell(nMids,1)...
                                     ) ...
                           );
                 
	allmpts = [nMids,coord2midpt(vec)];
    % normalise distances over range
    corner2corner = vector_dist(min(allmpts,[],2),max(allmpts,[],2));
    distances = 1-(distances ./ corner2corner);
    cost = E_d + sum(similarities.*distances);
    
    
    function sim = s( plane, nPlane )
        sim = acosd(dot(plane(2:4),nPlane(2:4)) / ...
             (norm(plane(2:4))*norm(nPlane(2:4))));
    end
    
    function dist = d( i, j )
        dist = vector_dist(i, j);
    end
end