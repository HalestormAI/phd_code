function [L_t,L_hist] = labelTracklets( T, L_p,im1_sz )
% Labels a set of tracklets, T with a set of cluster labels, L_t given the
% labels of the pixels they cross, L_p.
%
% INPUT:
%   T       The set of tracklets
%   L_p     The set of pixel labels
%   im_sz   Input image dimensions
%
% OUTPUT:
%   L_t     The set of tracklet labels
%   L_hist  Histogram of labels per tracklet

    if length(im1_sz) > 3 || length(im1_sz) < 2,
        error('Invalid image dimensions');
    end

    L_t = zeros(length(T)/2,1);
    
    LABELS = unique(L_p);
    L_hist = zeros( length(T),length(LABELS) );
    for t=1:2:length(T),
        px = getTrackletPx( T(:,t:t+1) );
        % Check bounds
        % Build histogram of tracklet labels
        for p=1:size(px,1)
            if px(p,1) < 1 || px(p,2) < 1 || px(p,1) > im1_sz(2) || px(p,2) > im1_sz(1),
                continue;
            end
            l = find(LABELS == L_p(px(p,2),px(p,1)));
            L_hist((t+1)/2,l) = L_hist((t+1)/2,l) + 1;
        end
        % Find most common histogram index
        [~,L_t((t+1)/2)] = max(L_hist((t+1)/2,:));
    end

    function px = getTrackletPx( t )
        [xs,ys] = bresenham( t(1,1),  t(2,1), t(1,2), t(2,2) );
        px = [xs,ys];
    end
end