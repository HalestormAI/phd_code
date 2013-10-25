function [err,rectTraj, rotated_N, rotated_P, rotated_d, rotation_axis] = hinged_rotation_solver( traj, boundary, N, P, angle, alpha )
% Rotates a plane (with trajectories) around an arbitrary axis, evaluating
% the error of the rotated trajectories.
%
% Usage:
%
%   [...] = HINGED_ROTATION_SOLVER( T, B, N, P, A, ALPHA )
%       Where:
%           T       Trajectories
%           B       Boundary Line in 3D Camera Coordinates
%           N       Normal of the other plane on the hinge (known)
%           P       A point on the plane - can usually use one of the
%                   boundary points.
%           A       The angle to rotate
%           ALPHA   The alpha parameter for the reconstruction, assumed to
%                   be known from earlier calculation.
%
%    [E] = HINGED_ROTATION_SOLVER( ... )             Returns the error from the rotated trajectories.
%    [E,RT] = HINGED_ROTATION_SOLVER( ... )          Returns the error and the rectified trajectories.
%    [E,RT,RN] = HINGED_ROTATION_SOLVER( ... )       Also returns the rotated normal.
%    [E,RT,RN,RP] = HINGED_ROTATION_SOLVER( ... )    And the rotated point.
%    [E,RT,RN,RP,RA] = HINGED_ROTATION_SOLVER( ... ) And the rotation axis (boundary line with some translation to meet the origin).
%
%   See also PLOT_HINGE_ROTATION_TEST, MULTIPLANE_LINEAR_COMBINATION


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
    [err,~,~,rectTraj] = errorfunc_traj( rotated_N(1:3), [rotated_d, alpha], traj, 0, @backproj_n );
end