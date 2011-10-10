function [best,best_error] = gridTree_enterNode( vec, level, MAX_LEVEL,PROPORTION, im_coords )
    
        if level >= MAX_LEVEL
            best = vec;
            best_error = mean(gp_iter_func(vec,im_coords).^2);
            return;
        end

        grid = generateFineGrid( vec, level );
        griderrors  = cell2mat(cellfun(@(x) mean(gp_iter_func(x,im_coords).^2), num2cell(grid,2), 'UniformOutput',false));
        [~,sortedids] = sort(griderrors);
        best_few = sortedids(1:ceil(length(griderrors)*PROPORTION));
        grid(best_few,:)
        fprintf('%d Level %d Nodes to traverse\n\n', length(best_few), level+1);
        for h = 1:length(best_few),
            % Enter grid, find errors
            fprintf('Entering Level %d, Node %d\n', level+1, h );
            [est(h,:), est_error(h)] = gridTree_enterNode( grid(best_few(h),:), level + 1, MAX_LEVEL,PROPORTION, im_coords );
        end
        
        [best_error, minidx] = min(est_error);
        best = est(minidx,:);
        
    end
