function [sideTrajectories,sideTrajectoryId] = multiplane_split_trajectories_for_line( trajectories, centre, angle, debug, debug_colour, debug_style )
% CURRENTLY DUAL PLANE ONLY
% ANGLE RANGE: -90:90 (in relation to x-axis)
    sideTrajectories = cell( 2, 1 );
    sideTrajectoryId = cell( 2, 1 );

    if nargin < 4
        debug = 0;
        debug_colour = [];
    elseif nargin < 5
        debug_colour = 'm';
    end
    
    if nargin < 6
        debug_style = '--';
    end
    
    for t=1:length(trajectories)
        sides = multiplane_line_side( centre, angle, trajectories{t}, debug, debug_colour, debug_style );
        debug = 0;
        [splits, splitIds] = SplitVec( sides, 'equal','split','index' );

        for s=1:length(splits)
            % Get the line side from the first element (add one as curr
            % range (0..1)
            sideTrajectories{splits{s}(1) + 1}{end+1} = trajectories{t}(:,splitIds{s});
            sideTrajectoryId{splits{s}(1) + 1}{end+1} = t;
        end
    end

end