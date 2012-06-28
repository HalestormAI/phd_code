function plane_details = paramsFromVideo( vidname, FPS )

    if nargin < 2
        FPS = 15;
    end

    load(vidname);

    
    trajectories_lgt2 = filterTrajectoryLengths( trajectories,4 );
    split = splitTrajectories(trajectories_lgt2,1);
    [traj_clusters,plane_details.matches,plane_details.assignment,plane_details.outputcost] = traj_cluster_munkres(split,FPS, 200, frame);
    plane_details.trajectories = recentreImageTrajectories( traj_clusters, frame );
    

    if exist('H','var')
        plane_details.camTraj = cellfun(@(x) H*makeHomogenous(x),plane_details.trajectories,'uniformoutput',false);
    elseif exist('calib_fn','var')
        plane_details.camTraj = PETSCalibrationParameters(calib_fn, traj_clusters);
    end

    allCamPoints = horzcat(plane_details.camTraj{:});
    allImPoints  = horzcat(trajectories_lgt2{:});

    limits = minmax(allImPoints);
    plane_details.imPlane = [ limits(1,1) limits(1,2) limits(1,2) limits(1,1);
                              limits(2,1) limits(2,1) limits(2,2) limits(2,2)];

    if exist('H','var')
        plane_details.camPlane = H*makeHomogenous(plane_details.imPlane);
    elseif exist('calib_fn','var')
         plane_details.camPlane = PETSCalibrationParameters(calib_fn, {plane_details.imPlane});
    end
    
    disp('DONE WITH C++');

    [plane_details.GT_N,plane_details.D] = planeFromPoints( allCamPoints, 100 );
    [plane_details.GT_theta,plane_details.GT_psi] = anglesFromN(plane_details.GT_N,0,'degrees');

    plane_details.GT_focal= 1;
    

    
end