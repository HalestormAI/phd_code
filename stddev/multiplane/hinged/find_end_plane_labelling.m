function starting_plane = find_end_plane_labelling( pixel_regions, smoothed_labelling, region_dims, avoid, planes )

    if nargin < 4
        avoid = [];
    end

    % Get ids of regions in terms of rectangle image
    sqreg = reshape(1:length(pixel_regions), region_dims);

    % Get xs and ys for scaling imagesc
    px_centres = [pixel_regions.centre];
    px_xs = unique(px_centres(1,:));
    px_ys = unique(px_centres(2,:));

    % Generate binary empty image (1 is full)
    empty_img =zeros(size(sqreg))';
    for i=1:size(sqreg,1)
        for j=1:size(sqreg,2)
            if ~pixel_regions(sqreg(i,j)).empty
                empty_img(j,i) = 1;
            end
        end
    end

    labels = unique(smoothed_labelling);
    labels(labels==0) = [];

    if nargin > 4
        figure;
        subplot(2,ceil((1+length(labels))/2),1);
        imagesc(px_xs, px_ys,empty_img)
        drawPlanes(planes,'image',0);
        view(0,90)
        % colormap gray;
    end
    label_imgs = cell(length(labels),1);


    all_component_areas = zeros(length(labels),1);

    % For each label, highlight each pixel centre
    for l=1:length(labels)
        label_imgs{l} = zeros(size(sqreg))';
        for i=1:size(sqreg,1)
            for j=1:size(sqreg,2)
                if smoothed_labelling(sqreg(i,j)) == labels(l)
                    label_imgs{l}(j,i) = 1;
                end
            end
        end
        label_imgs{l}(~empty_img) = 0;

        % Get all connected components and their properties
        label_components{l} = bwconncomp( label_imgs{l} );
        label_components_props{l} = regionprops(label_components{l});

        area_mean = mean([label_components_props{l}.Area]);
        all_component_areas(l) = area_mean;
        % remove all components sub-mean area
        for k=1:length(label_components_props{l})
            if label_components_props{l}(k).Area < area_mean
                label_imgs{l}(label_components{l}.PixelIdxList{k}) = 0;
            end
        end

        if nargin > 4
            subplot(2,ceil((1+length(labels))/2),l+1);
            imagesc(px_xs, px_ys, label_imgs{l});
            colormap gray;
            drawPlanes(planes,'image',0)
            view(0,90)
        end
    end

    attempts = 0;
    while 1

        plane_adjacencies = zeros(length(labels))
        adjacency_possibilities = combnk(labels,2)

        for p=1:length(adjacency_possibilities)
            i = adjacency_possibilities(p,1);
            j = adjacency_possibilities(p,2);
            adjpos = sub2ind(size(plane_adjacencies),i,j);
            adjpos2 = sub2ind(size(plane_adjacencies),j,i);

            plane_adjacencies([adjpos,adjpos2]) = multiplane_check_adjacency(label_imgs(adjacency_possibilities(p,:)));
        end

        plane_adjacencies

        % find all potential starting planes
        starting_planes = find(sum(plane_adjacencies)==1)
        avoid
        starting_plane = starting_planes(find(~ismember(starting_planes,avoid),1,'first'));
        
        if ~isempty(starting_plane)
            break;
        elseif attempts == 1
            labels
            starting_plane = labels(find(~ismember(labels,avoid),1,'first'))
            break;
        end
        attempts = 1;
        global_area_mean = mean(all_component_areas)-abs(2*std(all_component_areas));

        labels(all_component_areas < global_area_mean) = [];
    end
    
    function TF = multiplane_check_adjacency( imgs )

        img_1g = bwmorph(imgs{1},'thicken');
        img_2g = bwmorph(imgs{2},'thicken');

        TF = any(any((img_1g+img_2g)>=2));
    end

    %
    % px_empties = [pixel_regions.empty];
    %
    % drawPlanes(planes,'image',1,['k','k','k'])
    % scatter(px_centres(1,smoothed_labelling == 1),px_centres(2,smoothed_labelling == 1),'bo','filled')
    % scatter(px_centres(1,smoothed_labelling == 2),px_centres(2,smoothed_labelling == 2),'ro','filled')
    % scatter(px_centres(1,smoothed_labelling == 3),px_centres(2,smoothed_labelling == 3),'go','filled')
    % scatter(px_centres(1,px_empties),px_centres(2,px_empties),'ko','filled')
    % view(0,90)
end