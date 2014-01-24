function [models, linePoints, raw_assignments_st, region_centres_st, labelCost, min_costs] = multiplane_multiclass_svm( regions, hypotheses,labelCost, region_dims )

    
    traj_length_ratio = cellfun(@(x) sum(cellfun(@length,x))/length(x),{regions.traj});
    traj_length_ratio(isnan(traj_length_ratio)) = 0;
    
    tooshort = traj_length_ratio < 4;
    
    [regions(tooshort).empty] = deal(1);
    px_centres = [regions.centre];
    if nargin < 3
        labelCost = multiplane_calculate_label_cost( use_regions, hypotheses );
    end
    
    % Ignore any with error over mean
    [min_costs_st,raw_assignments_ns] = nanmin(labelCost);
%     [regions(min_costs > min_costs > (nanmean(min_costs))).empty] = deal(1);

%     raw_assignments = smooth_labels(region_dims, raw_assignments_ns, 10);
    raw_assignments = importance_smooth_labels( region_dims, raw_assignments_ns, min_costs_st, 50 );
    
    size(raw_assignments)
    [raw_assignments, hypotheses] = multiplane_break_same_orientation( raw_assignments, hypotheses, region_dims );
    [raw_assignments, hypotheses] = multiplane_remove_unused_labels( raw_assignments, hypotheses );
    

    %drawPlanes(planes,'image',1,['k','k','k'])
%     figure; hold on;
%     scatter(px_centres(1,raw_assignments_ns == 1),px_centres(2,raw_assignments_ns == 1),'bo','filled')
%     scatter(px_centres(1,raw_assignments_ns == 2),px_centres(2,raw_assignments_ns == 2),'ro','filled')
%     scatter(px_centres(1,raw_assignments_ns == 3),px_centres(2,raw_assignments_ns == 3),'go','filled')
%     scatter(px_centres(1,px_empties),px_centres(2,px_empties),'ko','filled')
%     
    
    raw_assignments_st = raw_assignments;
    
    
    
    u = unique(raw_assignments);
    num_classes = length(u);
    filtered_assignments = zeros(length(raw_assignments),1);
    for l=1:num_classes
        input_img = raw_assignments==u(l);
        output_img = filter_positives(input_img, region_dims);
        filtered_assignments(output_img) = u(l);
    end
    
    save filt raw_assignments filtered_assignments;
    figure;
    subplot(1,2,1)
    imagesc(reshape(raw_assignments,region_dims)')
    subplot(1,2,2)
    imagesc(reshape(filtered_assignments,region_dims)')

    toremove = or([regions.empty]', filtered_assignments==0);
    filtered_assignments = filtered_assignments(~toremove);
    min_costs = min_costs_st(~toremove);
    use_regions = regions(~toremove);
    
    region_centres = [use_regions.centre];
    region_centres_st = region_centres;


    
    %build models
    linePoints = cell(num_classes,1);
    starting_point = [];
    for k=1:num_classes
        tmplabels = unique(filtered_assignments);

        if length(tmplabels) > 2
            starting_point(k) = find_end_plane_labelling( regions, raw_assignments_st, region_dims, starting_point );
        else
            starting_point(k) = tmplabels(1);
        end
        
        if length(unique(filtered_assignments)) == 1
            linePoints(k:end) = [];
            break;
        end
        
        tmplabels        
        starting_point   
        starting_point(k)
        
        G1vAll = (filtered_assignments==starting_point(k));
        
        
        
        % here we want to filter G1vAll to remove sub-mean regions
%         G1vAll = filter_positives(G1vAll, region_dims);
        f = figure;
        models(k) = svmtrain(region_centres,G1vAll,'showPlot','true');
        linePoints{k} = multiplane_svm_get_line( models(k).FigureHandles{1} );
        
        
        
        % Need to take out any regions already used
        use_regions(G1vAll) = [];
        region_centres(:,G1vAll) = [];
        filtered_assignments(G1vAll) = [];
        unique(raw_assignments)
%         close(f);
    end
   
    
    function output = filter_positives( input, region_dims )
        length(input)
        sq_input = reshape(input,region_dims)';
        sq_output = sq_input;
        components = bwconncomp(sq_input);
        if components.NumObjects == 1
            output = input;
            return
        end

        props = regionprops(components);
        small_regions = find([props.Area] < mean([props.Area]));
        sq_output(vertcat(components.PixelIdxList{small_regions})) = 0;
        output = reshape(sq_output', numel(sq_output) ,1);
    end
end