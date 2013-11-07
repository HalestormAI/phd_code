function side = multiplane_line_side( line_centre, line_angle, point, debug, debug_colour, debug_style )
    
    if nargin < 4
        debug = 0;
        debug_colour = [];
    elseif nargin < 5
        debug_colour = 'm';
    end
    
    if nargin < 6
        debug_style = '--';
    end

    line_m = tand( line_angle );
    line_c = line_centre(2) - line_centre(1)*line_m;
    
    if debug
        endPoint(:,1) = [ (300 - line_c)/line_m; 300 ];
        endPoint(:,2) = [ (-400 - line_c)/line_m; -400];
        plot(endPoint(1,:), endPoint(2,:), strcat(debug_colour,debug_style),'LineWidth',2);
    end
    % x and y are given in point
    err = line_m*point(1,:) + line_c - point(2,:);
    
    side = err < 0;

end