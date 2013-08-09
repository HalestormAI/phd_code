normals = zeros(3,size(hypotheses,1));
for o = 1:size(hypotheses)
    normals(:,o) = normalFromAngle(hypotheses(o,1),hypotheses(o,2),'degrees');
end




%% Get the initial labelling
labelCost = NaN.*ones(size(hypotheses,1),length(regions));
smoothCost = zeros(size(hypotheses,1));
for e=1:size(hypotheses,1)
    for r=1:length(regions)
        if regions(r).empty
            labelCost(e,r) = Inf;
        else
            labelCost(e,r) = sum(errorfunc( hypotheses(e,1:2), [1,hypotheses(e,3)], traj2imc(regions(r).traj,1,1)).^2);
        end
    end
    
    
    % Build smooth cost: angle between planes.
    for f=e:size(hypotheses,1)
        n1 = normals(:,e);
        n2 = normals(:,f);
        smoothCost(e,f) = real(acos(dot(n1,n2) / (norm(n1)*norm(n2))));
        smoothCost(f,e) = smoothCost(e,f);
    end
end

% ... build matrix of image distance for each trajectory
distanceCost = zeros(length(regions));
for r1=1:length(regions)
    for r2=r1:length(regions)
        if r1==r2
            distanceCost(r1,r2) = NaN; %Can't match to itself
        else
            distanceCost(r1,r2) = vector_dist_c(regions(r1).centre, regions(r2).centre);
        end
        distanceCost(r2,r1) = distanceCost(r1,r2);
    end
    fprintf('\tRow %d of %d done.\n', r1, length(regions));
end