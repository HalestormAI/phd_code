function [planes,plane_params] = multiplane_make_planes( drawit, yAngles )

    if nargin < 2
        yAngles = [10,35,-10];  
    end
    
    
    NUM_PLANES = length(yAngles);
    SCALE = 5;
    
    planes = struct('world', cell(NUM_PLANES,1));

    rot = cell( NUM_PLANES, 1);
    for p = 1:NUM_PLANES
        rot{p} = makehgtform('yrotate',deg2rad(-yAngles(p)));
        rot{p} = rot{p}(1:3,1:3);
    end

    
    for p=1:NUM_PLANES
        if p==1
            planes(1).world  = add_plane( rot{1} );
        else
        planes(p).world  = add_plane( rot{p}, planes(p-1).world );
        end
    end
    
    
%     planes(1).world = rot{1}*([    0    0    1    1 ;
%                                    0    1    1    0 ;
%                                   -2   -2   -2   -2 ].*SCALE- T1)+T1;
%                               
%     planes(2).world = rot{2}*([    1    1    2    2 ;
%                                    0    1    1    0 ;
%                                   -2   -2   -2   -2].*SCALE - T2)+T2;
%                               
%     
%     T3 = repmat([planes(2).world(1,3);0;-planes(2).world(3,3)].*SCALE,1,4);
%     
%     
%     planes(3).world = rot{3}*([    repmat( (planes(2).world(1,3))/SCALE,1,2)    repmat( planes(2).world(1,3)/SCALE+1,1,2) ;
%                                    0    1    1    0 ;
%                                   repmat(planes(2).world(3,3)/SCALE,1,4)].*SCALE - T3)+T3;

    plane_params = cell(NUM_PLANES,1);
    for p = 1:NUM_PLANES
        planes(p).world = SCALE.*planes(p).world;
        [n,d] = planeFromPoints( planes(p).world,4,'svd' );
        plane_params{p} = [n',d];
    end

    if nargin == 1 && drawit
        drawPlane(planes(1).world);
        drawPlane(planes(2).world,'',0,'r');
        drawPlane(planes(3).world,'',0,'b');
    end
    
    function pln = add_plane( rot, previous_plane )
        if nargin < 2
            start = [ [0 0]; [1 0]; [-2 -2] ];
        else
            start = previous_plane( :, 3:4 );
        end
        origin = [ [0;0;0], [0;1;0] ];

        T = start - origin;
        T = T(:,1);
        T(2) = 0;
        
        T = repmat( T, 1,2 );
        
        pln = [start(:,[2 1]), rot*([start(1,1:2)+1; start(2:3,[1:2])] - T)+T];
    end
end