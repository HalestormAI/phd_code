function [worldPlane,camPlane,ROT] = createPlane( d, XDEG, ZDEG, GSIZE )

    if nargin < 1,
        d = 3;
    end
    if nargin < 2,
        XDEG = 75;
    end
    if nargin < 3,
        ZDEG = 0;
    end
    if nargin < 4,
        GSIZE = 4;
    end

    % Create a simulated square world-plane of <GSIZE>m, viewed by a bird's eye
    % camera <d>m above the ground
    worldPlane = [ 0      0 GSIZE GSIZE;
                   0  GSIZE GSIZE     0;
                  -1     -1    -1    -1].*d;


    % Assign camera rotations
    xRot = deg2rad( XDEG );
    zRot = deg2rad( ZDEG );

    rotMatX = makehgtform('xrotate', xRot );
    rotMatZ = makehgtform('zrotate', zRot );

    Ttrans  = makehgtform('translate',mean(worldPlane,2));

    ROT = rotMatZ*rotMatX;

    % Rotate camera by <XDEG> AOE and <ZDEG> yaw
    %  N.B. Camera defines origin and axes, therefore camera rotation is
    %  equivalent to rotating the world plane around the axis.
    camPlane = ROT(1:3,1:3)*worldPlane;
%     
%     drawPlane( camPlane );
%     drawPlane( worldPlane, '', 0, 'g' );
%     axis equal;

end