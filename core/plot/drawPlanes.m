function f = drawPlanes( planes_struct, field, newfig, colours )
% DRAWPLANES takes a plane struct array and draws the 
% planes from the specified field (defaults to 'image').
%
%   DRAWPLANES(P); Draws all the image planes in P
%   DRAWPLANES(P,'world'); Draws all the world planes in P
%   DRAWPLANES(P,'camera',1); Draws all the camera planes 
%                             in P in a new figure (default)
%   DRAWPLANES(P,'camera',0); Draws all the camera planes 
%                             in P in the current figure
%   DRAWPLANES(...,colours); Gives the colours for each plane
%
%   f = DRAWPLANES(P) Returns the figure handle
%
% See also DRAWPLANE
%
    valid = {'image','camera','world'};

    
    if nargin < 4 || isempty(colours)
        colours = ['k','b','r','m','c','g','y'];
    end
        
    if length(colours) < length(planes_struct)
        error('drawPlanes: Colours list must be at least as long as planes list.');
    end
    
    if nargin < 3 || newfig
        f = figure;
    else
        f = gcf;
    end
    
    % Currently undocumented, but can take a cell of planes in terms of
    % their coords, rather than a struct
    if iscell(planes_struct)
        hold on
        for p=1:length(planes_struct)
            pln = planes_struct{p};
            plot(pln(:,1), pln(:,2),strcat('-',colours(p)));
        end
        return
    end
    
    if nargin < 2 || isempty(field)
        field = 'image';
    elseif ~any(strncmp(field,valid,1))
        error('drawPlanes: Field must be one of: ''image'', ''camera'' or ''world''.');
    end
    
    
    for p=1:length(planes_struct)
        drawPlane(planes_struct(p).(field),'', 0, colours(p));
    end

end

% function drawPlanes( d, n_o, p, c, n_c, l, idx )
% %
% %  Input:
% %   d       Original value for d
% %   n_0     Normal of original plane
% %   p       Estimated plane arrays (for all iterations)
% %   c       Original coordinates (for all iterations)
% %   n_c     Noisy coordinates (for all iterations)
% %   l       Noise levels (for all iterations)
% %   idx     Iteration number
% 
% if nargin <= 6,
%    idx = 1;
% end
%     
% 
%     % Get the minimum and maximums
%     
%     mins = min( [min(c(:,:,idx),[],2),min(n_c(:,:,idx),[],2)], [], 2 )
%     maxs = max( [max(c(:,:,idx),[],2),max(n_c(:,:,idx),[],2)], [], 2 )
%     
%     figure,
%     m=ezmesh(@(x,y)getCartesianPlane(x,y,p(idx,1),p(idx,2:4)',n_c(:,:,idx )),[mins(1) maxs(1) mins(2) maxs(2)]);
%     set(m,'facecolor','none')
%     hold on,
%     m=ezmesh(@(x,y)getCartesianPlane(x,y,d,n_o,c(:,:,1)),[mins(1) maxs(1) mins(2) maxs(2)]);
%     set(m,'facecolor','none')
%     colormap([0.5,0.5,0.5]);
% %     
% %     drawcoords3( c(:,:,idx), sprintf('Original (green) against Estimated (red) Coordinates at %f noise.', l(idx)), 0, 'g');
% %     drawcoords3( n_c(:,:,idx), sprintf('Original (green) against Estimated (red) Coordinates at %f noise.', l(idx)), 0, 'r');
%     
%     title(sprintf('Original (green) against Estimated (red) Coordinates at %f noise.', l));
%     
%     