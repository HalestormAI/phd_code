function plane_details = paramsFromVideo( vidname, FPS )

    if nargin < 2
        FPS = 15;
    end

    load(vidname);

    trajectories_lgt2 = filterTrajectoryLengths( trajectories,4 );
    split = splitTrajectories(trajectories_lgt2,1);
    [plane_details.trajectories,plane_details.matches,plane_details.assignment,plane_details.outputcost] = traj_cluster_munkres(split,FPS, 50, frame);
    
    plane_details.camTraj = cellfun(@(x) H*makeHomogenous(x),plane_details.trajectories,'uniformoutput',false);

    allCamPoints = horzcat(plane_details.camTraj{:});
    allImPoints  = horzcat(trajectories{:});

    limits = minmax(allImPoints);
    plane_details.imPlane = [ limits(1,1) limits(1,2) limits(1,2) limits(1,1);
                              limits(2,1) limits(2,1) limits(2,2) limits(2,2)];

    plane_details.camPlane = H*makeHomogenous(plane_details.imPlane);

    [plane_details.GT_N,plane_details.D] = planeFromPoints( allCamPoints, 100 );
    [plane_details.GT_theta,plane_details.GT_psi] = anglesFromN(plane_details.GT_N,0,'degrees');

    plane_details.GT_focal= 1;
    

    
end