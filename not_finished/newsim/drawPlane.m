function [f,thegroup] = drawPlane( plane, ttl, newfig, colour, camera, marker )
    if nargin < 2,
        ttl = '';
    end
    if nargin < 3,
        newfig = 1;
    end
    if nargin < 4,
        colour = 'k';
    end
    if nargin < 5,
        camera = 0;
    end
    if nargin < 6,
        marker = 'o';
    end

    if newfig > 0,
        f = figure;
    else 
        f = gcf;
    end
    hold on
    thegroup = hggroup;
    for i=1:4
        id =  mod( i+1, 4 );
        if (id == 0)
            id = 4;
        end
        
        if size(plane,1) == 2
            lines = plot( plane(1,[i,id]),plane(2,[i,id]), sprintf('-%s%s', marker, colour) );
        else
            lines = plot3( plane(1,[i,id]),plane(2,[i,id]),plane(3,[i,id]), sprintf('-%s%s', marker, colour) );
        end
        set(lines, 'Parent', thegroup )

    end
    
%     if size(plane,1) == 3
%         [N,D] = planeFromPoints( plane,4 );
%         m=ezmesh(@(x,y) (D-N(1)*x-N(2)*y)/N(3),[min(plane(1,:)), max(plane(1,:)), min(plane(2,:)), max(plane(2,:))]);
%         set(m,'facecolor','none')  
%         set(m,'edgecolor',rgb(colour).*0.5)  
%        % colormap(rgb(colour).*0.5)
%     end
    xlabel('x');ylabel('y');zlabel('z');
    title(ttl);
    grid on
    if camera,
        scatter3(0,0,0,32,'ro');
        scatter3(0,0,0,32,'r*');
        
    end
    axis equal;
end