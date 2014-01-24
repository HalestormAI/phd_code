function planes = multiplane_random_plane_generator( chain_length, angles )

    % given one root plane, generate a chain of planes with random angles

    
    root_plane =    [  2    2    0    0
                       0    2    2    0
                      -1   -1   -1   -1 ];
                  
                  
    planes(1).world = root_plane;
    planes(1).ID = 'simulated-plane-1';
    
    
    signs = rand(chain_length-1,1);
    signs(signs >= 0.5) = 1;
    signs(signs < 0.5) = -1;
    
    % Get plane angles from Gaussian Dist. centred about 25 degrees.
    if nargin < 2
        angles = signs.*(round(normrnd(25,5,(chain_length-1),1)))
    end
    
    STRAIGHT_ON = 1;
    TURN_LEFT = 0;
    TURN_RIGHT = 2;
    
    AXIS_STRAIGHT_ON = [1,2];
    AXIS_TURN_LEFT = [2,3];
    AXIS_TURN_RIGHT = [1,4];
    
    TRANS_STRAIGHT_ON = [1,4];
    TRANS_TURN_LEFT = [2,1];
    TRANS_TURN_RIGHT = [1,2];
    
    for i=2:chain_length
        
        [axisidx, transidx] = get_direction( );
        
        translate = planes(i-1).world(:,transidx(1))-planes(i-1).world(:,transidx(2));
        pts = planes(i-1).world + repmat(translate,1,4);
        rotation_axis = planes(i-1).world(:,axisidx);
        planes(i-1).rotation_angle = angles(i-1);
        planes(i-1).rotation_axis = rotation_axis;
        planes(i).world = axis_rot(rotation_axis,pts,angles(i-1));
        planes(i).ID = sprintf('simulated-plane-%d',i);
    end
    
    function [axisidx,transidx] = get_direction( )
        num = STRAIGHT_ON;%round(normrnd(1,0.25,1,1));
        
%         [~,MINIDX] = min(abs(rnum - [0 1 2]))
%         
%         num = MINIDX - 1;
        
        if num == STRAIGHT_ON
            axisidx = AXIS_STRAIGHT_ON;
            transidx = TRANS_STRAIGHT_ON;
        elseif num <= TURN_LEFT
            axisidx = AXIS_TURN_LEFT;
            transidx = TRANS_TURN_LEFT;
        elseif num >= TURN_RIGHT
            axisidx = AXIS_TURN_RIGHT;
            transidx = TRANS_TURN_RIGHT;
        else
            num
        end
        
    end
end