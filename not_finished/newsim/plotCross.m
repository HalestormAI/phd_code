function grp = plotCross( cntr, lim, colourSpec, labels )
    % INPUT:
    %   cntr [x,y,z]       Cross Centre
    %   *lim [ minx maxx   Limits for lines
    %          miny maxy
    %          minz maxz]
    %   *colourSpec        Colour specification
    %   *labels            The x,y,z labels for the figure. Vertical array
    %                      of strings.
    %
    % OUTPUT:
    %   grp                Handle for the group of lines.
    
    if nargin < 2 || isempty(lim)
        if length(cntr) == 3
            lim = reshape(axis',2,3)'
        else
            lim = reshape(axis',2,2)'
        end
    end
    
    if nargin < 3
        colourSpec = 'm--';
    end
    hold on;
    grp = hggroup;
    
    if length(cntr) == 3
        l1 = plot3( [cntr(1),cntr(1)], [cntr(2),cntr(2)], lim(3,:), colourSpec,'LineWidth',1 );
        l2 = plot3( lim(1,:), [cntr(2),cntr(2)], [cntr(3),cntr(3)], colourSpec,'LineWidth',1 );
        l3 = plot3( [cntr(1),cntr(1)], lim(2,:), [cntr(3),cntr(3)], colourSpec,'LineWidth',1 );
        set([l1,l2,l3], 'Parent', grp);
    elseif length(cntr) == 2
        l1 = plot( [cntr(1),cntr(1)], lim(2,:), colourSpec );
        l2 = plot( lim(1,:), [cntr(2),cntr(2)], colourSpec );
        set([l1,l2], 'Parent', grp);
    end
    if nargin >= 4
        xlabel(labels(1,:))
        ylabel(labels(2,:))
        if length(cntr) == 3
            zlabel(labels(3,:))
        end
    end
end
