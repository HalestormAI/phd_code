function [pt,xy0] = circle_intersection( circles )

    
    counter = 1;
    intersects = zeros( floor( size(circles,1)*(size(circles,1)/2) ),2 );
    for c=1:size(circles,1)
        cc1 = circles(c,:);
        for c2=c:size(circles,1)
            cc2 = circles(c2,:);
            [xi,yi] = circcirc(cc1(1),cc1(2),cc1(3),cc2(1),cc2(2),cc2(3));
            intersects(counter,:) = [xi(1),max(yi)];
            counter = counter + 1;
        end
    end
    
    xy0 = nanmean(intersects);

    pt = fsolve(@(x) iterator(x, circles), xy0 );
    
    function E = iterator( in, circles )
        
        x0 = in(1);
        y0 = in(2);
        
        xs = circles(:,1);
        ys = circles(:,2);
        rs = circles(:,3);
        
        E = (xs-x0).^2 + (ys-y0).^2 - rs.^2; % == 0 give correct intersection
        
    end
    
end

% TODO:
%   - Circle intersection optimisation
%        - Find all cr