function regions = multiplane_generate_regions( traj, NUM_REGIONS, RADIUS )

    allPoints = [traj{:}];
    
    if nargin < 2
        NUM_REGIONS = 5;
    end
    
    if nargin < 3
        RADIUS = max(range(allPoints,2)./ (2*NUM_REGIONS));
    end

    centres = randperm(length(allPoints),NUM_REGIONS);
    
    regions = struct('centre',num2cell(allPoints(:,centres),1),'radius',RADIUS);

end