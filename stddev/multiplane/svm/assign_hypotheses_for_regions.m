function new_hypotheses = assign_hypotheses_for_regions( hypotheses, regions )
% Use munkres to find best assignment of hypothesis to regions

    if size(hypotheses,1) ~= length(regions)
        error('Region list length must be equal to the number of hypotheses');
    end
    
    fixed_d = (size(hypotheses,2) < 4);
        

    % For each region-hyopthesis pair, generate sum-squared error given
    % rectification
    errorMat = Inf.*ones(length(regions), size(hypotheses,1));
    for r=1:length(regions)
        for h=1:size(hypotheses,1)
            if fixed_d
                d = 5;
            else
                d = hypotheses(h,4);
            end
            errorMat(r,h) =  sum(errorfunc_traj( hypotheses(h,1:2), [d, hypotheses(h,3)], regions(r).traj ).^2);
        end
    end

    % Feed matrix into munkres for assignment
    hypothesis_ordering = munkres(errorMat);
    
    [findrows,~] = find( hypothesis_ordering );
    [~,hypothesis_ids] = sort(findrows);
    
    new_hypotheses = hypotheses(hypothesis_ids,:);

end