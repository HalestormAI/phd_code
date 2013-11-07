function camera_pos = multiplane_camera_position( world_centre, params )
% Get the camera position based on the world centre and a set of parameters
% including camera height and rotation.
%
% Camera is assumed to stay central on the x-axis.

    offset = [0;10*tan(deg2rad(params.camera.rotation(2)));10];
    camera_pos = world_centre + offset;
end