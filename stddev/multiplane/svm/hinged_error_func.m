function E = hinged_error_func( orientation, scales, trajectories, constraints, WEIGHT )
    % Taking the edge of rectified plane 1, re-calculate the error for
    % plane 2.
        
    if nargin < 5
        DEBUG = false;
    end
   
    
    E = Inf*ones(length(trajectories)+size(constraints,2),1);
    meanLength = zeros(length(trajectories),1);
    stdLength = zeros(length(trajectories),1);

    lengths = cellfun(@(x) size(x,2), trajectories);

    longEnough = trajectories(lengths>3);    
    
    rectTrajectories = cellfun(@(x) backproj_c(orientation(1),orientation(2), ...
                                             scales(1),scales(2), x), ...
                                             longEnough,'uniformoutput', false);
        
    N = normalFromAngle( orientation(1), orientation(2) );
    D = scales(1);

    for i=1:length(rectTrajectories)
        lengths = vector_dist_c(rectTrajectories{i});
        lengths(lengths == Inf) = 10e20; 
        meanLength(i) = mean(lengths);
        stdLength(i) = std(lengths);
        E(i) = stdLength(i) / meanLength(i);
        if isnan(E(i))
            orientation,scales
            lengths
            fprintf('Mean Length: %.3f\n',meanLength(i));
            error('ERROR IS NaN');
        end
    end
    
    toUse = E ~= Inf;
    
    E = E(toUse) * priors( rectTrajectories(toUse) );
    
    % Now append point constraints
    unweighted_errors = zeros(size(constraints,2),1);
    for c=1:size(constraints,2)
        unweighted_errors(c) = distance_from_plane( N, D, constraints(:,c) );
%         E(length(trajectories)+c) = WEIGHT*unweighted_error;
    end
   E = WEIGHT*sum(unweighted_errors)*E;
    
    function P = priors( traj )
        
        speeds = cellfun(@vector_dist_c, traj,'un',0);
        means = zeros(length(speeds),1);
        for s=1:length(speeds)
            means(s) = mean(speeds{s}(speeds{s} ~= Inf));
        end
        P = std(means);
    end
% 
%     function D = distance_from_plane( n, d, p )
%         
%         root = sqrt( sum(n.^2) );
%         D = abs(sum(n.*p) - d) / root;
%     end
end