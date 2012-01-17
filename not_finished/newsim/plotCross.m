function grp = plotCross( cntr, lim, colourSpec, labels )
    % INPUT:
    %   cntr [x,y,z]       Cross Centre
    %   lim [ minx maxx    Limits for lines
    %         miny maxy
    %         minz maxz]
    %   *colourSpec        Colour specification
    %   *labels            The x,y,z labels for the figure. Vertical array
    %                      of strings.
    %
    % OUTPUT:
    %   grp                Handle for the group of lines.
    if nargin < 3
        colourSpec = 'm-';
    end
    hold on;
    grp = hggroup;
    l1 = plot3( [cntr(1),cntr(1)], [cntr(2),cntr(2)], lim(3,:), colourSpec );
    l2 = plot3( lim(1,:), [cntr(2),cntr(2)], [cntr(3),cntr(3)], colourSpec );
    l3 = plot3( [cntr(1),cntr(1)], lim(2,:), [cntr(3),cntr(3)], colourSpec );
    
    if nargin >= 4
        xlabel(labels(1,:))
        ylabel(labels(2,:))
        zlabel(labels(3,:))
    end
    set([l1,l2,l3], 'Parent', grp);
end