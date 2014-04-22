function labelCost = multiplane_calculate_label_cost( regions, hypotheses )
    labelCost = NaN.*ones(size(hypotheses,1),length(regions));
    parfor e=1:size(hypotheses,1)
        rowCost = NaN.*ones(1,length(regions))
        for r=1:length(regions)
            if regions(r).empty
                rowCost(1,r) = NaN;
            else
                rowCost(1,r) = sum(errorfunc( hypotheses(e,1:2), [1,hypotheses(e,3)], traj2imc(regions(r).traj,1,1)).^2);
            end
        end
        labelCost(e,:) = rowCost(:);
    end
end