function [err,rectTraj, rotated_N, rotated_P, rotated_d, rotation_axis] = hinged_rotation_solver( traj, boundary, N, P, angle, alpha )

    T = -boundary(:,1);
    rotation_axis = boundary + repmat(T,1,2);

    Rz = makehgtform('zrotate',acos(dot(rotation_axis(1:2,2),[1,0])));
    Ry = makehgtform('yrotate',pi+acos(dot(rotation_axis(2:3,2),[1,0])));
    Rx = makehgtform('xrotate',deg2rad(angle));
    

    pre_rotmat = Ry*Rz;%makehgtform('axisrotate', ax, deg2rad(angle));    
    full_rot = pre_rotmat\(Rx*pre_rotmat); % Rotate to x-axis, rotate in a-axis, reverse initial rot.
    
    rotated_N = full_rot * makeHomogenous(N);
    rotated_P = full_rot * makeHomogenous(P+T) - makeHomogenous(T); % translate, rotate, translate back


    rotated_d = sum(rotated_N(1:3).*rotated_P(1:3)); % ax+by+cz = d;

    [new_theta, new_psi] = anglesFromN( rotated_N,0,'degrees' );
    normalFromAngle(new_theta,new_psi, 'degrees');
%     rotated_N

    % MAYBE JUST USE ERROR FUNC?
    %new_traj = backproj_c( new_theta, new_psi, rotated_d, alpha, traj );
    [err,~,~,rectTraj] = errorfunc_traj( rotated_N(1:3), [rotated_d, alpha], traj );
end