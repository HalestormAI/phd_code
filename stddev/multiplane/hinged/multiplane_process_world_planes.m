function [planes, trajectories, params, plane_params] = multiplane_process_world_planes (planes, params)

    plane_params = cell(length(planes),1);
    for p = 1:length(planes)
        [n,d] = planeFromPoints( planes(p).world,4,'svd' );
        n = ensureOutwardNormal(n);
        [n',d]
        plane_params{p} = [n',d];
    end

    plane_names = {planes.ID}';
    
    % !~/make.sh multiplane_add_trajectories.cpp
    traj = multiplane_add_trajectories({planes.world}',plane_params,params.trajectory.speeds,params.trajectory.drns, plane_names);

    % Get the camera position so we know how to transform the scene.
    params.camera.position = multiplane_camera_position(mean([planes.world],2), params);
    [planes,camTraj] = world2camera( planes, traj, params);
    [planes,imTraj] = camera2image( planes, camTraj, 1/params.camera.focal );
    trajectories.world = traj;
    trajectories.camera = camTraj;
    trajectories.image = imTraj;


    function n = ensureOutwardNormal( n )
    % make sure we're getting the outward normal to prevent odd behaviour
    % when generating trajectories. In this scenario, we want the normal
    % pointing upwards (W.R.T z-axis).
        if( n(3) < 0 )
            n = -1*n;
        end
    end
end