function costs = multiplane_recalculate_costs( regions, labelling, hypotheses )

    if matlabpool('size') < 3 
        matlabpool 3;
    end
    costs = NaN*ones(length(regions),1);
    parfor r=1:length(regions)
        e = labelling(r);
        
        costs(r) = sum(errorfunc( hypotheses(e,1:2), [1,hypotheses(e,3)], traj2imc(regions(r).traj,1,1)).^2);
    end

end