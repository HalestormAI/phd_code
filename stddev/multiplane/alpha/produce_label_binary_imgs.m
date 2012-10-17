function regionTrajectories = produce_label_binary_imgs( imTraj, regions, labelling, planes, drawit )

if nargin < 4
    drawit = 0;
end

img_offset = min([regions.centre],[],2)-regions(1).radius - 1;
img_dims = (max([regions.centre],[],2)+regions(1).radius-img_offset)';
% img_dims = img_dims(end:-1:1);


if drawit
    figure;
    subplot(3,2,1)
    drawPlane(planes(1).image,'',0); drawPlane(planes(2).image,'',0,'r');
    drawtraj( imTraj,'',0)
    multiplane_overlay_sliding_regions( regions, labelling );
end

img = cell(3,1);
labels = unique(labelling);
for l=1:length(labels)
    img{l} = zeros(img_dims);
    
%     these_regions = regions(labelling==labels(l));
%     img{l} = multiplane_binary_from_region( these_regions, img_dims, img_offset );

    for r=1:length(regions)
        if labelling(r) == labels(l),
            img{l} = multiplane_pixels_for_region( img_offset, regions(r), img{l});
        end
    end
    if drawit
        subplot(3,2,l+1)
        imagesc(img_offset(1),img_offset(2),img{l}'); colormap(gray);
        axis ij;
        title(sprintf('Binary region for label %d',l-1));
    end
end

regionTrajectories = generate_irregular_region_trajectories( imTraj, img, img_offset );


if drawit
    colours = ['k','b','m','g','c'];
    for r=1:length(regionTrajectories)
        subplot(3,2,r+1);
        drawtraj(regionTrajectories{r},'',0,colours(r));
        set(findall(gca,'Type','Line'),'LineWidth',3);
    end
end