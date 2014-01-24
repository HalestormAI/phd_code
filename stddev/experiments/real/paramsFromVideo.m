function plane_details = paramsFromVideo( vidname, FPS )
    tic;
    if nargin < 2
        FPS = 7;
    end
    disp('Loading Data');
    load(vidname);

    plane_details.frame = frame;
    
    disp('Filtering Trajectories...')
    trajectories_lgt2 = filterTrajectoryLengths( trajectories,4 );
    
    disp('Splitting Trajectories...')
    split = splitTrajectories(trajectories_lgt2,0);
    length(split)
    disp('Clustering Trajectories (May take some time)...')
    [cluster_struct,plane_details.matches,plane_details.assignment,plane_details.outputcost] = traj_cluster_munkres(split,FPS, 1500, frame, [0.5,0.5]);
    
    plane_details.trajectories = recentreImageTrajectories( cluster_struct.representative, frame );
    

    disp('Loading Calibration Data...')
    if exist('H','var')
        plane_details.camTraj = cellfun(@(x) H*makeHomogenous(x),plane_details.trajectories,'uniformoutput',false);
    elseif exist('calib_fn','var')
        plane_details.camTraj = PETSCalibrationParameters(calib_fn, plane_details.trajectories);
    end

    disp('Creating image and ground-truth plane data');
    allCamPoints = horzcat(plane_details.camTraj{:});
    allImPoints  = horzcat(trajectories_lgt2{:});

    limits = minmax(allImPoints);
    plane_details.imPlane = [ limits(1,1) limits(1,2) limits(1,2) limits(1,1);
                              limits(2,1) limits(2,1) limits(2,2) limits(2,2)];

    if exist('H','var')
        plane_details.camPlane = H*makeHomogenous(plane_details.imPlane);
    elseif exist('calib_fn','var')
         [plane_details.camPlane, plane_details.rmat, plane_details.tmat, plane_details.focal] = PETSCalibrationParameters(calib_fn, {plane_details.imPlane});
    end
    
    [plane_details.GT_N,plane_details.D] = planeFromPoints( allCamPoints, 3, 'cross' );
    [plane_details.GT_theta,plane_details.GT_psi] = anglesFromN(plane_details.GT_N,0,'degrees');

    plane_details.GT_focal= 1;
    fprintf('Done in %.3f seconds', toc);
end
