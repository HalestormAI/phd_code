function f = drawPathPlots( acceptable, H, highlight, layout )

    if nargin < 3,
        highlight = [];
    end

    if nargin < 4,
        cols = 5;
        rows = 4;
    else
        cols = layout(1);
        rows = layout(2);
    end

    f = zeros( ceil(43/(4*5)), 1);

    
    for i=1:length(acceptable),
        if mod(i,cols*rows) == 1,
            f(floor(i/(cols*rows))+1) = figure;
        end
        
        %i-floor(i/(cols*rows))*(cols*rows)
        sid = mod(i,20);
        if sid == 0,
            sid = 20;
        end
        s = subplot(4,5, sid);
        C = makeHomogenous(acceptable{i});
        if any(i==highlight),
            set(s,'Color','w',...
            'XColor','r',...
            'YColor','r',...
            'ZColor','r')
        end
        drawcoords3(C,'',0,'b');
        drawcoords3(C(:,2:end-1),'',0,'r');
    end
end

