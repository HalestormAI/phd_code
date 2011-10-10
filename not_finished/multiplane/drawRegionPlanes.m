function f = drawRegionPlanes( estplanes, regions, im_coords, planes )
    global colours;

    f = figure;
    subplot(1,2,1);
    
    drawcoords(im_coords,'',0,'k');
    for i=1:length(regions),
        if ~isempty(regions{i}),
            drawcoords(regions{i},'',0,colours(i));
        end
    end
    
    subplot(1,2,2);
    hold on;

    for r=1:length(regions)
        if ~isempty(regions{r}),
            c = find_real_world_points(regions{r},iter2plane( estplanes(r,:) ));
            mins = min( [min(c,[],2)], [], 2 );
            maxs = max( [max(c,[],2)], [], 2 );
            m=ezmesh(@(x,y)getCartesianPlane(x,y,estplanes(r,1),estplanes(r,2:4)',c),[mins(1) maxs(1) mins(2) maxs(2)]);
            
            colormap(ones(1,3).*0.5);
            set(m,'facecolor','w','edgecolor',colours(r));
            drawcoords3(c,'',0,colours(r));
        end
    end
    planes
    if nargin >= 4,
        for p=1:length(planes),
            m = ezmesh(...
                @(x,y) getCartesianPlane(x,y, planes(p).d, planes(p).n, planes(p).points),...
                [ ...
                    min(planes(p).points(1,:)), ...
                    max(planes(p).points(1,:)), ...
                    min(planes(p).points(2,:)), ...
                    max(planes(p).points(2,:)) ...
                ], ...
                10 ...
               );
               
            colormap(ones(1,3).*0.5);
            set(m,'facecolor','k','edgecolor',colours(p));
        end
        axis auto
    end
    
    axis auto;
    view(-100,14);
end