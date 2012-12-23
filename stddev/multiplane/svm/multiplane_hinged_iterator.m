
function [all_err,minerror,e_angles,e_d,inits,errors] ...
        = multiplane_hinged_iterator( trajectories, thetas, psis, ds, F, C, W_c )


    if nargin < 3
        thetas = 1:10:89;
    end
    if nargin < 4
        psis = -60:10:60;
    end
    if nargin < 5
        ds = 0:20;
    end

    fsolve_options;

    inits = zeros(length(thetas)*length(psis)*length(ds),3);
    count = 1;
    for t = 1:length(thetas)
        for p = 1:length(psis)
            for d = 1:length(ds)
                inits(count,:) = [thetas(t),psis(p),ds(d)];
                count = count + 1;
            end
        end
    end


    all_err = ones( size(inits,1), 1 ) .* Inf;
    errors = cell( size(inits,1), 1) ;
    for i=1:size(inits,1);
        t = inits(i,1);
        p = inits(i,2);
        d = inits(i,3);
        errors{i} = hinged_error_func([t,p],[d,F], traj2imc(trajectories,1,1), C, W_c);
        all_err(i) = sum(errors{i}.^2);
        if ~mod(i,500)
            fprintf('Completed %d of %d rows (%.3f%%)\n', i,length(inits),100*(i/length(inits)));
        end
    end

    [minerror,min_err_id] = min( all_err );

    e_theta = inits(min_err_id,1);
    e_psi = inits(min_err_id,2);
    e_d = inits(min_err_id,3);

    e_angles = [e_theta,e_psi];


end