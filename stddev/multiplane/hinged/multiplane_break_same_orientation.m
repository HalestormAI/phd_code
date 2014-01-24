function [new_labelling, new_hypotheses] = multiplane_break_same_orientation( old_labelling, old_hypotheses, region_dims )

    new_hypotheses = old_hypotheses;

    % reshape labelling #
    sqreg = reshape(1:length(old_labelling), region_dims);
    sq_labelling = reshape(old_labelling,region_dims)';
    new_sq_labelling = sq_labelling;
    
    labels = unique(old_labelling);
    
    for l=1:length(labels)
        % find connected components
        label_img = sq_labelling==labels(l);
        components = bwconncomp(label_img);
        
        if components.NumObjects == 1
            fprintf('Finished for label %d\n',labels(l));
            continue;
        end
        
        props = regionprops(components);

        % filter to remove those beneath mean
        small_regions = find([props.Area] < mean([props.Area]));
        
        % Filter small regions
        label_img(vertcat(components.PixelIdxList{small_regions})) = 0;
        
        remaining_components = components.NumObjects - length(small_regions);
        if remaining_components == 1
            fprintf('Finished for label after removing smalls %d\n',labels(l));
            continue;
        end
        
        
%         figure; 
%         subplot(1,2,1)
%         imagesc( sq_labelling );

        % Rerun component analysis
        components = bwconncomp(label_img);
        
        % For all but the first component
        for r=2:components.NumObjects
            new_id = size(old_hypotheses,1)+1;
            % create new_hypotheses(end+1,:) = hypothesis(repeated,:);
            new_hypotheses(new_id,:) = old_hypotheses(labels(l),:);
            
            % change the label in the labelling matrix
            new_sq_labelling(components.PixelIdxList{r}) = new_id;
        end
%         
%         subplot(1,2,2)
%         imagesc( new_sq_labelling );
        
        
        % pick the one that best fits the repeated hyopthesis
%         errs = Inf*ones(components.NumObjects,1);
%         for c=1:components.NumObjects
%             ids = components.PixelIdxList(c);
%             errs(c) = sum(label_costs(ids).^2);
%         end
% 
%         [~,best_region] = min(errs);
        
    end
    
    new_labelling = reshape(new_sq_labelling', numel(new_sq_labelling) ,1);
%     figure;
%     imagesc(new_sq_labelling');
%     new_labels = unique(new_labelling);
%     % remove unused labels from hypotheses matrix
%     hids = 1:size(new_hypotheses,1);
%     [~,notin] = setdiff(hids, new_labels)
% 
%     new_hypotheses(notin) = [];
    
end
