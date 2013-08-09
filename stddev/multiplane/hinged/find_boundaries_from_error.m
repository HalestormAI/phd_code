function boundary_pts = find_boundaries_from_error( regions, planes, labelCost, WINDOW_DISTANCE )

    image_size = diff(minmax([regions.centre])')';
    num_rows = image_size(2)/WINDOW_DISTANCE + 1; % + 1 because we start at (0,0)
    num_cols = image_size(1)/WINDOW_DISTANCE + 1;

    rawCostVector = labelCost;
    rawCostVector(rawCostVector==Inf) = 0;
    errimg = reshape(rawCostVector,num_cols, num_rows);
    errthresh = errimg > mean(mean(errimg));

    [H,T,R] = hough(errthresh);
    P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
    lines = houghlines(errthresh,T,R,P,'FillGap',5,'MinLength',7);

    lineEnds  = gmeans([vertcat(lines.point1) vertcat(lines.point2)],0.1);
    % Take floor and ceil so we can get the mean once we've converted region id to image coords
    floorEnds = floor(lineEnds); 
     ceilEnds = ceil(lineEnds);

    drawPlanes(planes,[],1);

    boundary_pts = cell(size(lineEnds,1),1);
    
    for i=1:size(lineEnds,1)
        ceilpts(:,1) = regions(sub2ind(size(errimg), ceilEnds(i,2), ceilEnds(i,1))).centre;
        ceilpts(:,2) = regions(sub2ind(size(errimg), ceilEnds(i,4), ceilEnds(i,3))).centre;
        floorpts(:,1) = regions(sub2ind(size(errimg), floorEnds(i,2), floorEnds(i,1))).centre;
        floorpts(:,2) = regions(sub2ind(size(errimg), floorEnds(i,4), floorEnds(i,3))).centre;
        pts = .5*(ceilpts+floorpts);
        boundary_pts{i} = pts;

        plot(pts(1,:),pts(2,:),'m--','LineWidth',2);
    end
end