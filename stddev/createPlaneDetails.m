function plane_details = createPlaneDetails( orientation, constants, noise )
% Generate a simulated plane and trajectories upon it.
%
% Input:
%   Orientation: [theta, psi]
%   Constants:   [d, alpha]
%   Noise:       [inter-var, intra-var, height-var] in range (0, ... ,1)
% 
    [worldPlane, camPlane, imPlane, rot] = createCameraPlane( orientation, constants, 10 );
    [~,startframes,camTraj] = addTrajectoriesToPlane( worldPlane, rot, 100, 2000, 1, noise(1), noise(2),[],noise(3) ); 
    trajectories = cellfun(@(x) traj2imc(wc2im(x,constants(2)),1,1), camTraj, 'uniformoutput', false);

    plane_details = struct( );
    plane_details.trajectories = trajectories;
    plane_details.imPlane = imPlane;
    plane_details.startframes = startframes;
    plane_details.camPlane = camPlane;
    plane_details.camTraj = camTraj;
    plane_details.GT_theta = orientation(1);
    plane_details.GT_psi = orientation(2);
    plane_details.GT_focal = constants(2);
    plane_details.rotation = rot;

end
