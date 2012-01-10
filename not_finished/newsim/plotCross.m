function grp = plotCross( cntr, lim, colourSpec, labels )
    
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