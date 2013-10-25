function opoints = axis_rot( bound, points, yrota_deg )
% AXIS_ROT Rotates a set of 3D points about an axis by ANGLE degrees.
%
% Usage:
%
%   OUT = AXIS_ROT( AXIS, PTS, ANGLE );
%       AXIS should be a pair of 3x1 points in a 3x2 matrix.
%       PTS is a 3xN matrix representing N 3D points
%       ANGLE is the rotation angle, in degrees

    trans = bound(:,1);

    diff = bound(:,1)-bound(:,2);

    xrota = atan(diff(3)/diff(2));
    if isnan(xrota)
        xrota = 0;
    end
    zrota = atan(diff(1)/diff(2));
    if isnan(xrota)
        zrota = 0;
    end

    rotmat = makehgtform('zrotate',zrota,'xrotate',-xrota);

    tpoints = points - repmat(trans,1,size(points,2));
    rpoints = rotmat(1:3,1:3)*tpoints;
    
    yrot = makehgtform('yrotate',deg2rad(yrota_deg));
    yrotpoints = yrot(1:3,1:3)*rpoints;
    
    unrotpoints = rotmat(1:3,1:3)\yrotpoints;
    
    opoints = unrotpoints + repmat(trans,1,size(points,2));
   
end