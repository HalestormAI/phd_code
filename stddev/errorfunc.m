function [E,meanLength,stdLength] = errorfunc( orientation, scales, trajectories, DEBUG )   

    if nargin < 4
        DEBUG = false;
    end
    E = Inf*ones(length(trajectories),1); % Play on the safe side :)
    meanLength = zeros(length(trajectories),1);
    stdLength = zeros(length(trajectories),1);

    lengths = cellfun(@(x) size(x,2), trajectories);

    longEnough = trajectories(lengths>3);

%     rectTrajectories = cellfun(@(x) backproj(orientation, scales, x), longEnough,'uniformoutput', false);
      rectTrajectories = cellfun(@(x) backproj_c(orientation(1),orientation(2), ...
                                                 scales(1),scales(2), x), ...
                                                 longEnough,'uniformoutput', false);
    for i=1:length(rectTrajectories)
        lengths = vector_dist(rectTrajectories{i});
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

    E = E.*priors( rectTrajectories );
    badScores = find( E == Inf );

    E(badScores) = [];
    stdLength(badScores) = [];
    meanLength(badScores) = [];

    if DEBUG
        DEBUG_p = backproj(orientation,scales,DEBUG);
        drawPlane( DEBUG_p );
        drawcoords3(traj2imc(rectTrajectories,1,1),'',0);
    end
    
    function P = priors( traj )
         stds = cellfun(@(x) std(vector_dist(x)), traj);
         means = cellfun(@(x) mean(vector_dist(x)), traj);
         
         P = stds ./ means;
    end

end
