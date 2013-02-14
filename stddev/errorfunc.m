function [E,meanLength,stdLength, rectTrajectories] = errorfunc( orientation, scales, trajectories, DEBUG )   
    
    if nargin < 4
        DEBUG = false;
    end
    E = Inf*ones(length(trajectories),1); % Play on the safe side :)
    meanLength = zeros(length(trajectories),1);
    stdLength = zeros(length(trajectories),1);

    lengths = cellfun(@(x) size(x,2), trajectories);

    longEnough = trajectories(lengths>3);
    
%     disp('REMEMBER THIS IS USING THE NON-STANDARD BACKPROJ (errorfunc.m)');

    if length(orientation) == 3
        rectTrajectories = cellfun(@(x) backproj_func(orientation, scales, x), longEnough,'uniformoutput', false);
    else
        rectTrajectories = cellfun(@(x) backproj_c(orientation(1),orientation(2), ...
                                     scales(1),scales(2), x), ...
                                     longEnough,'uniformoutput', false);
    end
       
      
                                             
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
    
    E = E(toUse) + priors( rectTrajectories(toUse) );
    stdLength(~toUse) = [];
    meanLength(~toUse) = [];

    if DEBUG
        DEBUG_p = backproj(orientation,scales,DEBUG);
        drawPlane( DEBUG_p );
        drawcoords3(traj2imc(rectTrajectories,1,1),'',0);
    end
    
    function P = priors( traj )
        
        speeds = cellfun(@vector_dist, traj,'un',0);
        means = zeros(length(speeds),1);
        for s=1:length(speeds)
            means(s) = mean(speeds{s}(speeds{s} ~= Inf));
        end
        P = std(means);
    end

end
