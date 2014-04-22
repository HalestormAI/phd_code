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

    
%     return

    tpoints = points - repmat(trans,1,size(points,2));
    tbound = bound - repmat(trans,1,size(bound,2));

    diff = bound(:,1)-bound(:,2);
    xrota = atan(diff(3)/diff(2));
    if isnan(xrota)
        xrota = 0;
    end
    rotmatX = makehgtform('xrotate',-xrota);
    rxpoints = rotmatX(1:3,1:3)*tpoints;
    rxbound = rotmatX(1:3,1:3)*tbound;
    
    diff = rxbound(:,1) - rxbound(:,2);
    zrota = atan(diff(1)/diff(2));
    if isnan(xrota)
        zrota = 0;
    end
        
    rotmatZ = makehgtform('zrotate',zrota);
    
    rpoints = rotmatZ(1:3,1:3)*rxpoints;
    
    yrot = makehgtform('yrotate',deg2rad(yrota_deg));
    yrotpoints = yrot(1:3,1:3)*rpoints;
    
    unrotpoints = rotmatX(1:3,1:3)\(rotmatZ(1:3,1:3)\yrotpoints);
    
    
    opoints = unrotpoints + repmat(trans,1,size(points,2));
    
   
end