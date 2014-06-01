function [f,thegroup] = drawcoords_fast( imcoords, ttl, newfig, colour, lw, marker )
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
    if nargin < 5 || isempty(lw),
        lw = 1;
    end
    if nargin < 6,
        marker = '-o';
    end

    if newfig > 0,
        f = figure;
        title(ttl);
    else 
        f = gcf;
    end
    hold on
    
    imc = {};
    for i=1:2:length(imcoords)
        imc{end+1} = imcoords(:,i:(i+1));
    end
    imcnan = cellfun(@(x) [x [NaN;NaN]], imc,'un',0);
    im_coords_nan = [imcnan{:}];
    
    
    if ischar(colour),
        lines = plot(im_coords_nan(1,:),im_coords_nan(2,:), sprintf('%s%s', marker, colour), 'LineWidth',lw );
    elseif size(colour,1) == (length(imcoords)/2),
        lines = plot(im_coords_nan(1,:),im_coords_nan(2,:), sprintf('%s-', marker), 'Color', colour(cid2mpid(i),:), 'LineWidth',lw );
    else
        lines = plot(im_coords_nan(1,:),im_coords_nan(2,:), sprintf('%s', marker), 'Color', colour, 'LineWidth',lw, 'MarkerSize', 10 );
    end
%     if nargin >= 5 && max(size(axes_size)) > 1,
%         axis( [0 axes_size(1) 0 axes_size(2)] );
%     end
end
