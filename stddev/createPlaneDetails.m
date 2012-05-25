function plane_details = createPlaneDetails( orientation, constants, noise )

    [worldPlane, camPlane, imPlane, rot] = createCameraPlane( orientation, constants, 10 );
    [worldTraj,~,camTraj] = addTrajectoriesToPlane( worldPlane, rot, 20, 2000, 1, noise(1), noise(2) ); 
    imPlane = wc2im( camPlane, constants(2) );
    trajectories = cellfun(@(x) traj2imc(wc2im(x,constants(2)),1,1), camTraj, 'uniformoutput', false);

    plane_details = struct( );
    plane_details.trajectories = trajectories;
    plane_details.imPlane = imPlane;
    plane_details.camTraj = camTraj;
    plane_details.GT_theta = orientation(1);
    plane_details.GT_psi = orientation(2);

end
