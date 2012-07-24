function outTraj = multiplane_trajectories_for_region( inTraj, region )

    t_ids = [];
    for t=1:length(inTraj)
        inRegion = zeros(length(inTraj{t}),1);
        traj = inTraj{t};
        for p=1:length(traj)
            inRegion(p) = vector_dist(region.centre, traj(:,p)) < region.radius;
        end
        
%         fprintf('T%d  -  Num in: %d, Num Total: %d\n',t,length(find(inRegion)),ceil(length(inTraj{t})));
        
        if length(find(inRegion)) > length(inTraj{t})/4
            t_ids(end+1) = t;
        end
    end
    
    outTraj = inTraj(t_ids);
end