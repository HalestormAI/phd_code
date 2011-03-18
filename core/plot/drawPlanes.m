function drawPlanes( d, n_o, p, c, n_c, l, idx )
%
%  Input:
%   d       Original value for d
%   n_0     Normal of original plane
%   p       Estimated plane arrays (for all iterations)
%   c       Original coordinates (for all iterations)
%   n_c     Noisy coordinates (for all iterations)
%   l       Noise levels (for all iterations)
%   idx     Iteration number

if nargin <= 6,
   idx = 1;
end
    

    % Get the minimum and maximums
    
    mins = min( [min(c(:,:,idx),[],2),min(n_c(:,:,idx),[],2)], [], 2 )
    maxs = max( [max(c(:,:,idx),[],2),max(n_c(:,:,idx),[],2)], [], 2 )
    
    figure,
    m=ezmesh(@(x,y)getCartesianPlane(x,y,p(idx,1),p(idx,2:4)',n_c(:,:,idx )),[mins(1) maxs(1) mins(2) maxs(2)]);
    set(m,'facecolor','none')
    hold on,
    m=ezmesh(@(x,y)getCartesianPlane(x,y,d,n_o,c(:,:,1)),[mins(1) maxs(1) mins(2) maxs(2)]);
    set(m,'facecolor','none')
    colormap([0.5,0.5,0.5]);
%     
%     drawcoords3( c(:,:,idx), sprintf('Original (green) against Estimated (red) Coordinates at %f noise.', l(idx)), 0, 'g');
%     drawcoords3( n_c(:,:,idx), sprintf('Original (green) against Estimated (red) Coordinates at %f noise.', l(idx)), 0, 'r');
    
    title(sprintf('Original (green) against Estimated (red) Coordinates at %f noise.', l));
    
    