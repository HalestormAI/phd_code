function [errors regions meanLength, stdLength] = hinged_errorfunc( regions, region_parents, boundaries2d, angles, root_hypothesis )
    
%% Rectify trajectories
    

    regions = hinged_reconstruction( root_hypothesis, angles, boundaries2d, region_parents, regions );

    %% Now work out the error based on the rectification.

    meanLength = cell(length(regions),1);
    stdLength = cell(length(regions),1);
    Ec = cell(length(regions),1);
    
    
    for r=1:length(regions)
        rectTrajectories = regions(r).reconstructed;
        
        for i=1:length(rectTrajectories)
            if length(rectTrajectories{i}) < 4
                continue;
            end
            lengths = traj_speeds(rectTrajectories{i});
            lengths(lengths == Inf) = 10e20; 
            meanLength{r}(i) = mean(lengths);
            stdLength{r}(i) = std(lengths);
            Ec{r}(i) = stdLength{r}(i) / meanLength{r}(i);
            if isnan(Ec{r}(i))
                meanLength{r}
                stdLength{r}
                rectTrajectories{i}
                lengths
                fprintf('Mean Length: %.3f\n',meanLength{r}(i));
                error('ERROR IS NaN');
            end
        end

        toUse = Ec{r} ~= Inf;

        Ec{r} = Ec{r}(toUse) + priors( rectTrajectories(toUse) );
        stdLength{r}(~toUse) = [];
        meanLength{r}(~toUse) = [];
    end
   
    errors = [Ec{:}];
    
    function P = priors( traj )

        speeds = cellfun(@traj_speeds, traj,'un',0);
        means = zeros(length(speeds),1);
        for s=1:length(speeds)
            if isempty(speeds{s})
                continue;
            end
            means(s) = mean(speeds{s}(speeds{s} ~= Inf));
        end
        P = std(means);
    end
end