function E_regions = combined_alpha_iterator( ALPHAS, THETAS, PSIS, D, REGIONS )

    E_regions = cell( length(ALPHAS), length(THETAS), length(PSIS) );

    % Outside loops get parameters
    num_alpha = length(ALPHAS);
    options = optimset( 'Display', 'off', ...
                    'Algorithm',{'levenberg-marquardt',.005}, ...
                    'MaxFunEvals', 10000, ...
                    'MaxIter', 1000, ...
                    'TolFun',1e-12 ...
                   );
    
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
                    
%                     [~,fval] = fsolve(@(x) errorfunc_traj( x(1:2), [D,x(3)], REGIONS(r).traj ),[theta,psi,alpha], options);
                    %errors{i} = errorfunc([t,p],[D,f], trajectories);
%                     E_r{r} = sum(fval);
                    E_r{r} = errorfunc_traj( [theta,psi], [D,alpha], REGIONS(r).traj );
                end
                E_r_a{t,p}   = cellfun(@(x) sum(x.^2), E_r);
            end
            fprintf('\t\tTheta %d of %d complete.\n',t,length(THETAS));
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