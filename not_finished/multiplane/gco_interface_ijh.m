SMOOTHCOEFF    = 1;
NEIGHBOURCOEFF = 100;
LABELCOEFF     = 100;

h = GCO_Create(length(midpoints),size(estplanes,1));

% Build cost matrix - plane x vector
labelCost = zeros(size(estplanes,1),length(midpoints));
smoothCost = zeros(size(estplanes,1));

DISTS = squareform(pdist(midpoints'));
DISTS2 = 1-DISTS/max(max(DISTS));

for p=1:size(estplanes,1),
    plane = estplanes(p,:);
    % Build datacost: dist_eqn
    for v=1:length(midpoints),
        vec = im_coords(:,mpid2cid(v));
        labelCost(p,v) = abs(dist_eqn( plane, vec ));
    end
    % Build smooth cost: angle between planes.
    for q=1:size(estplanes,1),
        nPlane = estplanes(q,:);
        smoothCost(p,q) = real(acos(dot(plane(2:4),nPlane(2:4)) / ...
                          (norm(plane(2:4))*norm(nPlane(2:4)))));
    end
end

% Calculate neighbourhood using image distances
neighbourDists = squareform(pdist(midpoints'));
% Invert (change cost to affinity)
maxW = max(max(neighbourDists));
neighbourWeights = 1 - (neighbourDists/maxW);
% Set diagonal to zero (cannot neighbour self)
neighbourWeights = neighbourWeights - diag(diag(neighbourWeights));

GCO_SetDataCost( h, LABELCOEFF.*labelCost );
GCO_SetSmoothCost( h, SMOOTHCOEFF.*smoothCost );
GCO_SetNeighbors( h, NEIGHBOURCOEFF .* neighbourWeights );
GCO_Expansion(h);
labelling = GCO_GetLabeling(h);

% Now have a labelling, using assigned plane estimates, rectify scene
% coords_rect = zeros(3,length(im_coords));
% figure;
% hold on
% disp_error = zeros(length(im_coords),1);
% for v=1:length(midpoints),
%     cids = mpid2cid(v);
%     pid  = labelling(v);
%     c = find_real_world_points(im_coords(:,cids),iter2plane( estplanes(pid,:) ));
%     plot3( [coords(1,cids(1)),c(1,1)], [coords(2,cids(1)),c(2,1)], [coords(3,cids(1)),c(3,1)],'r')
%     plot3( [coords(1,cids(2)),c(1,2)], [coords(2,cids(2)),c(2,2)], [coords(3,cids(2)),c(3,2)],'r')
%     coords_rect(:,cids) = c;
%     disp_error(cids) = vector_dist(coords(:,cids),c);
% end
% drawcoords3(coords_rect,'',0)
% figure, hist(disp_error,100);
