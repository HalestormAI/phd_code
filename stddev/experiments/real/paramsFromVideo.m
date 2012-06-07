function plane_details = paramsFromVideo( vidname )

    load(vidname);

    lengths = cellfun(@(x) size(x,2), trajectories);
    longestIds = (find(lengths>300));
    chosen = longestIds(randi(length(longestIds),1,20));

    plane_details.trajectories = traj2imc(trajectories(chosen),10,1);
    
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

    clear trajectories allCamPoints allImPoints limits;
    
end