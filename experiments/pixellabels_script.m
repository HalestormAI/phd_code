WINSIZE = 32;
tracklet_px = cell(size(im1,1),size(im1,2));

% Preprocess tracklet pixel locations
for i=1:2:length(im_coords),
    [xs,ys] = bresenham( im_coords(1,i), im_coords(2,i), ...
                         im_coords(1,i+1),im_coords(2,i+1) );
                     
    for j=1:length(xs), 
        if xs(j) < 1 || ys(j) < 1 || xs(j) > size(im1,2) || ys(j) > size(im1,1),
%             [xs(j),ys(j)]
            continue;
        end
        tracklet_px{ys(j),xs(j)} = unique([tracklet_px{ys(j),xs(j)}, i]);
    end
end

figure;
imagesc(im1);
hold on;
labels = zeros(size(im1,1),size(im1,2));
for x = WINSIZE/2+1:size(im1,2)-WINSIZE/2,
    for y = WINSIZE/2+1:size(im1,1)-WINSIZE/2,
        winstart = [y,x]-WINSIZE/2;
        winend   = [y,x]+WINSIZE/2;

        % Get the tracklet idxs that pass through window
        CHOSENPX = tracklet_px(winstart(1):winend(1),winstart(2):winend(2));
        CHOSENPX_COL = reshape(CHOSENPX,numel(CHOSENPX),1);
        VECTORS = unique([CHOSENPX_COL{:}]);
        
        if length(VECTORS) >= 4,
            % For each centre, find sum squared error for vectors
            sumerr = zeros(size(kcntr,1),1);
            for k=1:size(kcntr,1),
                ls = zeros(length(VECTORS),1);
                for i=1:length(VECTORS),
                    p = im_coords(:, sort([VECTORS(i), VECTORS(i)+1]));
                    ls(i) = dist_eqn(kcntr(k,:),p) + 1;
                end
                sumerr(k) = std(ls);
            end
            % Now pick cluster with minimum err
            [~,labels(y,x)] = min(sumerr);
        end
    end
end
imshow(labels./size(kcntr,1));
imsc1=imagesc(im1);
alpha(imsc1,0.5)
drawcoords(im_coords,'',0,'g')