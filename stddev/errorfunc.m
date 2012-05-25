function [E,meanLength,stdLength] = errorfunc( orientation, scales, trajectories, DEBUG )

    if nargin < 4
        DEBUG = false;
    end

    E = Inf*ones(length(trajectories),1); % Play on the safe side :)
    meanLength = zeros(length(trajectories),1);
    stdLength = zeros(length(trajectories),1);

    lengths = cellfun(@(x) size(x,2), trajectories);

    longEnough = trajectories(lengths>3);

    rectTrajectories = cellfun(@(x) backproj(orientation, scales, x), longEnough,'uniformoutput', false);

    for i=1:length(rectTrajectories)
        lengths = vector_dist(rectTrajectories{i});
        meanLength(i) = mean(lengths);
        stdLength(i) = std(lengths);
        E(i) = stdLength(i) / meanLength(i);
        if isnan(E(i))
            fprintf('Mean Length: %.3f\n',meanLength(i));
%            error('ERROR IS NaN');
        end
    end

    badScores = find( E == Inf );

    E(badScores) = [];
    stdLength(badScores) = [];
    meanLength(badScores) = [];

    if DEBUG
        DEBUG_p = backproj(orientation,scales,DEBUG);
        drawPlane( DEBUG_p );
        drawcoords3(traj2imc(rectTrajectories,1,1),'',0);
    end

end
