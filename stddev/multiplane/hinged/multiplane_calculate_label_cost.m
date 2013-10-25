function labelCost = multiplane_calculate_label_cost( regions, hypotheses )
    labelCost = NaN.*ones(size(hypotheses,1),length(regions));
    for e=1:size(hypotheses,1)
        for r=1:length(regions)
            if regions(r).empty
                labelCost(e,r) = Inf;
            else
                labelCost(e,r) = sum(errorfunc( hypotheses(e,1:2), [1,hypotheses(e,3)], traj2imc(regions(r).traj,1,1)).^2);
            end
        end
    end
end