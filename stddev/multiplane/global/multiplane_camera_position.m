function camera_pos = multiplane_camera_position( world_centre, params )
% Get the camera position based on the world centre and a set of parameters
% including camera height and rotation.
%
% Camera is assumed to stay central on the x-axis.

%     offset = [0;10*tan(deg2rad(params.camera.rotation(2)));10];

    % Start with point at the origin
    origin = zeros(3,1);
    new_pt = origin + [0;0;params.camera.height];

    %Now rotate in x
    rotations = makehgtform( 'zrotate', deg2rad(params.camera.rotation(1)), 'xrotate', deg2rad(params.camera.rotation(2)));
    
    offset = rotations*makeHomogenous(new_pt);
    
    camera_pos = world_centre + offset(1:3);
end