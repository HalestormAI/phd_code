function planes = multiplane_random_plane_generator( chain_length )

    % given one root plane, generate a chain of planes with random angles

    
    root_plane =    [  2    2    0    0
                       0    2    2    0
                      -1   -1   -1   -1 ];
                  
                  
    planes(1).world = root_plane;
    
    angles = (round(rand(chain_length-1,1)*30)-15)*2
    
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