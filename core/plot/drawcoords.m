function [f,thegroup] = drawcoords( imcoords, ttl, newfig, colour, lw, marker )
% Draw a set of 2D image coordinates on 2D plot
%   Input:
%       coords          A set of 3D coordinates
%       [ttl = '']      Title for the figure
%       [newfig = 1]    0 for draw on same figure, 1 for new figure
%       [colour = 'k']  Colour string
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
        marker = 'o';
    end

    if newfig > 0,
        f = figure;
        title(ttl);
    else 
        f = gcf;
    end
    hold on
    
    imcoords = ( imcoords );
     thegroup = hggroup;
    for i=1:2:size(imcoords,2)
        if ischar(colour),
            lines = plot( imcoords(1,i:i+1), imcoords(2,i:i+1), sprintf('-%s%s', marker, colour), 'LineWidth',lw );
        else
            lines = plot( imcoords(1,i:i+1), imcoords(2,i:i+1), sprintf('%s--', marker), 'Color', colour, 'LineWidth',lw, 'MarkerSize', 10 );
        end
        set(lines, 'Parent', thegroup )    
    end
    
     xlabel('x');ylabel('y');
    if nargin >= 2,
        title(ttl);
    end
    
%     if nargin >= 5 && max(size(axes_size)) > 1,
%         axis( [0 axes_size(1) 0 axes_size(2)] );
%     end
end