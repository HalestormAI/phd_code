function [sideTrajectories, sideTrajectoryId] = multiplane_split_trajectories_for_line_pts( imTraj, lPts, debug, debug_colour, debug_style )
    global planes;

    % Handle args
    if nargin < 3
        debug = [];
    end
    if nargin < 4
        debug_colour = [];
    end
    if nargin < 5
        debug_style = [];
    end
    if ~isempty(debug) && debug
        drawPlane(planes(1).image);drawPlane(planes(2).image,'',0,'r')
    end
    
    xvals = lPts(1,:)';
    yvals = lPts(2,:)';

    linePoints = [xvals(~isnan(xvals)), yvals(~isnan(yvals))] % Line points is transpose of coord system.

    % Get angle of line
    angles1 = atan2( diff(linePoints([1,end],2)), diff(linePoints([1,end],1)) );

    % Get vertical angle
    angles2 = atan2( 1, 0);

    % Get difference
    angle = rad2deg(angles1-angles2)-90;

    % Centre of line
    centre = mean(linePoints([1,end],:))';

    [sideTrajectories,sideTrajectoryId] = multiplane_split_trajectories_for_line( imTraj, centre, angle, debug, debug_colour, debug_style );
    
    if ~isempty(debug) && debug
        drawtraj(sideTrajectories{1},'',0,'b')
        drawtraj(sideTrajectories{2},'',0,'m')
    end
end