function output_plane = reorder_square_plane( plane, TOL )
% Reorders a plane assuming it will be square by minimising the difference
% between each edge's lengths.

    if nargin < 2
        TOL = 1e-10;
    end

    % N.B. There's got to be a faster, more sensible way to do this, maybe
    % when I have more time I'll look for it...
    orderings = perms(1:4);
    
    for o=1:length(orderings)
        score = range(vector_dist(traj2imc(plane(:,orderings(o,:)),1,1)));
        if score < TOL 
            output_plane = plane(:,orderings(o,:));
            return
        end
    end
    
    error('No orderings found with error below tolerance...');
end