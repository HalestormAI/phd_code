function E_regions = combined_alpha_iterator( ALPHAS, THETAS, PSIS, D, REGIONS )

    E_regions = cell( length(ALPHAS), length(THETAS), length(PSIS) );

    % Outside loops get parameters
    num_alpha = length(ALPHAS);
    
    parfor a=1:length(ALPHAS)
        fprintf('\tIterating over %d nodes and %d regions.\n',length(THETAS)*length(PSIS), length(REGIONS));
        alpha = ALPHAS(a);
        
        E_r_a = cell(length(THETAS), length(PSIS));
        for t=1:length(THETAS)
            theta = THETAS(t);
            for p=1:length(PSIS)
                psi = PSIS(p);

                % For a given parameter set, get the combined error across
                % all regions
                E_r = cell(length(REGIONS),1);
                for r=1:length(REGIONS)
                    E_r{r} = errorfunc_traj( [theta,psi], [D,alpha], REGIONS(r).traj );
                end
                E_r_a{t,p}   = cellfun(@(x) sum(x.^2), E_r);
            end
        end
        E_regions_for_a{a} = E_r_a;
        fprintf('\tAlpha %d of %d complete.\n',a,num_alpha);
    end
    
    % Post processing (necessary for parfor)
    for a=1:length(ALPHAS)
        for t=1:length(THETAS)
            for p=1:length(PSIS)
                E_regions{a,t,p} = E_regions_for_a{a}{t,p};
            end
        end
    end
    
end