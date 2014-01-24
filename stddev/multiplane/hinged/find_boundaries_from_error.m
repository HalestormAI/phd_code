function [boundary_pts,errthresh,errimg] = find_boundaries_from_error( regions, planes, labelCost, WINDOW_DISTANCE, do_not_skel )

    image_size = diff(minmax([regions.centre])')'
    num_rows = floor(image_size(2)/WINDOW_DISTANCE + 1); % + 1 because we start at (0,0)
    num_cols = floor(image_size(1)/WINDOW_DISTANCE + 1);
    
    num_rows*num_cols
    rawCostVector = labelCost;
    rawCostVector(abs(rawCostVector)==Inf) = min(rawCostVector);
    
    errimg = reshape(rawCostVector,num_cols, num_rows);
    
    figure; 
    
%   Do a bit of tidying on the heat regions
    %Gaussian blur to remove small blobs
    errimg_b = errimg;%imfilter(errimg,fspecial('gaussian',[5 5],2));

    errthresh = errimg_b > nanmean(nanmean(errimg_b));% + 2*nanstd(nanstd(errimg_b));
    
    % Now we have the heat map regions, use opening to get rid of small
    % areas
    errthresh = bwmorph(errthresh,'close');
    
    line_params = regionprops(errthresh,'Orientation','Centroid','MajorAxisLength');
    
    lineEnds = zeros(length(line_params),4);
    for i=1:length(line_params)
        lineEnds(i,:) = params_to_line( line_params(i) );
    end
    
%     nnz(errthresh)
%     if nargin < 5 || ~do_not_skel 
%         errthresh = bwmorph(errthresh,'skel',5);
%     end
%     size(errthresh)
%     subplot(1,2,1);
    imagesc(errimg_b);
%     subplot(1,2,2)
figure
    imagesc(errthresh);
    hold on;
    for i=1:size(lineEnds,1)
      plot(lineEnds(i,[1 3]), lineEnds(i,[2 4]), 'g--','LineWidth',2)
    end
% 
%     [H,T,R] = hough(errthresh);
%     P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
%     
%     lines = houghlines(errthresh,T,R,P,'FillGap',round(num_cols/20),'MinLength',round(num_cols/20));
% %     
% %     figure, imagesc(errthresh), hold on
% %     max_len = 0;
% %     for k = 1:length(lines)
% %        xy = [lines(k).point1; lines(k).point2];
% %        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% % 
% %        % Plot beginnings and ends of lines
% %        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
% %        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% % 
% %        % Determine the endpoints of the longest line segment
% %        len = norm(lines(k).point1 - lines(k).point2);
% %        if ( len > max_len)
% %           max_len = len;
% %           xy_long = xy;
% %        end
% %     end
% % 
% %     
% % 
%     allLineEnds = [vertcat(lines.point1) vertcat(lines.point2)];
%     if isempty(allLineEnds)
%         % If we didn't find any lines, we shouldn't have used skel, so call
%         % again without it. [boundary_pts,errthresh] = find_boundaries_from_error( pixel_regions, planes, min(labelCost), 2 );
%         warning('find_boundaries_from_error: Lines was empty. Repeating without skel');
%         [boundary_pts,errthresh] = find_boundaries_from_error( regions, planes, labelCost, WINDOW_DISTANCE, 1 );
%         return;
%     end
%     hold on;
%     for i=1:size(allLineEnds,1)
%         plot(allLineEnds(i,[1 3]), allLineEnds(i,[2 4]),'g--','LineWidth',3);        
%     end
% %     [~,lineEnds] = kmeans([vertcat(lines.point1) vertcat(lines.point2)], length(planes)-1,'emptyaction','drop');%gmeans([vertcat(lines.point1) vertcat(lines.point2)],0.1);
%     lineEnds = gmeans(allLineEnds,0.001,'pca','gamma');
%         
    % Take floor and ceil so we can get the mean once we've converted region id to image coords
    floorEnds = floor(lineEnds);
    floorEnds(:,[1 3]) = min(floorEnds(:,[1 3]),num_rows);
    floorEnds(:,[2 4]) = min(floorEnds(:,[2 4]),num_cols);
    floorEnds(floorEnds < 1) = 1;
    
    ceilEnds = ceil(lineEnds);
    ceilEnds(:,[1 3]) = min(ceilEnds(:,[1 3]),num_rows);
    ceilEnds(:,[2 4]) = min(ceilEnds(:,[2 4]),num_cols);
    ceilEnds(ceilEnds < 1) = 1;
    
    drawPlanes(planes,[],1);

    boundary_pts = cell(size(lineEnds,1),1);
    
    for i=1:size(lineEnds,1)
        ceilpts(:,1) = regions(sub2ind(size(errimg), ceilEnds(i,2), ceilEnds(i,1))).centre;
        ceilpts(:,2) = regions(sub2ind(size(errimg), ceilEnds(i,4), ceilEnds(i,3))).centre;
%        size(errimg),floorEnds(i,2),floorEnds(i,1)
        floorpts(:,1) = regions(sub2ind(size(errimg), floorEnds(i,2), floorEnds(i,1))).centre;
        floorpts(:,2) = regions(sub2ind(size(errimg), floorEnds(i,4), floorEnds(i,3))).centre;
        pts = .5*(ceilpts+floorpts);
        boundary_pts{i} = pts;

        plot(pts(1,:),pts(2,:),'m--','LineWidth',2);
    end


    function pts = params_to_line( params )
        dx = (params.MajorAxisLength/2)*cosd(-params.Orientation);
        dy = (params.MajorAxisLength/2)*sind(-params.Orientation);
        pts = [params.Centroid-[dx dy], params.Centroid+[dx dy]];
    end
end
