function [planes,plane_params] = multiplane_make_planes( drawit )
    NUM_PLANES = 2;
    yAngles = [0,25];

    SCALE = 5;

    rot = cell( NUM_PLANES, 1);
    for p = 1:NUM_PLANES
        rot{p} = makehgtform('yrotate',deg2rad(-yAngles(p)));
        rot{p} = rot{p}(1:3,1:3);
    end
    T1 = repmat([0;0;-2].*SCALE,1,4);
    T2 = repmat([1;0;-2].*SCALE,1,4);

    planes(1).world = rot{1}*([    0    0    1    1 ;
                                   0    1    1    0 ;
                                  -2   -2   -2   -2 ].*SCALE- T1)+T1;
    planes(2).world = rot{2}*([    1    1    2    2 ;
                                   0    1    1    0 ;
                                  -2   -2   -2   -2].*SCALE - T2)+T2;

    plane_params = cell(NUM_PLANES,1);
    for p = 1:NUM_PLANES
        [n,d] = planeFromPoints( planes(p).world );
        plane_params{p} = [n',d];
    end

    if nargin == 1 && drawit
        drawPlane(planes(1).world);
        drawPlane(planes(2).world,'',0,'r');
    end
end