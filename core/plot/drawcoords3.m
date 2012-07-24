function [f,thegroup] = drawcoords3( coords3, ttl, newfig, colour, lw, marker, camera )
% Draw a set of 3D world coordinates on 3D plot
%   Input:
%       coords          A set of 3D coordinates
%       [ttl = '']      Title for the figure
%       [newfig = 1]    0 for draw on same figure, 1 for new figure
%       [colour = 'k']  Colour string
%       [camera = 0]    Draw Camera at (0,0,0)'
%
%   Output: 
%       f   figure handle

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
        lw = 1;
    end
    if nargin < 6,
        marker = '-o';
    end
    if nargin < 7,
        camera = 0;
    end

    if newfig > 0,
        f = figure;
    else 
        f = gcf;
    end
    
    hold on
    if iscell(coords3)
        cellfun(@(x) drawcoords3( x, ttl, 0, colour, lw, marker ), coords3);
    else
        thegroup = hggroup;
        for i=1:2:size(coords3,2)
            if i+1 <= size(coords3,2)
                lines = plot3( coords3(1,i:i+1), coords3(2,i:i+1), coords3(3,i:i+1), sprintf('%s%s', marker, colour) );
                set(lines, 'Parent', thegroup )
            end
        end
    end
    
    xlabel('x');ylabel('y');zlabel('z');
    title(ttl);
    grid on
    if camera,
        scatter3(0,0,0,32,'ro');
        scatter3(0,0,0,32,'r*');
        axis([ min(0,min(coords3(1,:))), max(0,max(coords3(1,:))), ...
               min(0,min(coords3(2,:))), max(0,max(coords3(2,:))), ...
               min(0,min(coords3(3,:))), max(0,max(coords3(3,:))) ] );
    end
end