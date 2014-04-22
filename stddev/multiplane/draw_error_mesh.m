function draw_error_mesh( planes, region_centres, min_errors )

    xs = region_centres(1,:)';
    ys = region_centres(2,:)';
    zs = min_errors';
    
    size(xs)
    size(ys)
    size(zs)
    
    drawPlanes(planes,'',0);
    
    xlin = linspace(min(xs),max(xs),500);
    ylin = linspace(min(ys),max(ys),500);
    
    [X,Y] = meshgrid(xlin,ylin);
    f = TriScatteredInterp(xs,ys,log10(zs));
    Z = f(X,Y);

    
    ss = surf(X,Y,10*Z);
    set(ss,'EdgeAlpha',0)
    
end
