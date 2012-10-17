function E_regions = combined_alpha_iterator( ALPHAS, THETAS, PSIS, D, REGIONS )

%     E         = cell( length(ALPHAS), length(THETAS), length(PSIS) );
%     E_ssd     = Inf.*ones([length(ALPHAS), length(THETAS), length(PSIS)]);
    E_regions = cell( length(ALPHAS), length(THETAS), length(PSIS) );

    % Outside loops get parameters
    num_alpha = length(ALPHAS);
    
%     E_for_a = cell(length(ALPHAS),1);
    parfor a=1:length(ALPHAS)
        alpha = ALPHAS(a);
        
%         E_a = cell(length(THETAS), length(PSIS));
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
%                 E_a{t,p}     = vertcat(E_r{:});
                E_r_a{t,p}   = cellfun(@(x) sum(x.^2), E_r);
            end
        end
%         E_for_a{a}   = E_a;
        E_regions_for_a{a} = E_r_a;
        
        fprintf('Alpha %d of %d complete.\n',a,num_alpha);
    end
    
    for a=1:length(ALPHAS)
        for t=1:length(THETAS)
            for p=1:length(PSIS)
%                 E{a,t,p}         = E_for_a{a}{t,p};
                E_regions{a,t,p} = E_regions_for_a{a}{t,p};
%                 E_ssd(a,t,p)     = sum(E{a,t,p}.^2);
            end
        end
    end
    
end