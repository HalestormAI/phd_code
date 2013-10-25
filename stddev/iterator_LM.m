function [ssd_errors,minerror,E_angles,E_focal,inits] = iterator_LM( D, plane_details, thetas, psis,focals, options )

if nargin < 3
    thetas = 1:10:89;
end
if nargin < 4
    psis = -60:10:60;
end
if nargin < 5
    focals = 10.^(-4:4);
end

fsolve_options;

inits = zeros(length(thetas)*length(psis)*length(focals),3);
count = 1;
for t = 1:length(thetas)
    for p = 1:length(psis)
        for f = 1:length(focals)
            inits(count,:) = [thetas(t),psis(p),focals(f)];
            count = count + 1;
        end
    end
end

ssd_errors = ones( size(inits,1), 1 ) .* Inf;
iter_result = cell( size(inits,1), 1) ;
    warning('REMEMBER TO TAKE OUT FOCALS FIX (iterator_LM, line 33');
for i=1:size(inits,1);
    t = inits(i,1);
    p = inits(i,2);
    f = inits(i,3);
    [iter_result{i},fval] = fsolve(@(x) errorfunc( x(1:2), [D,0.0014], plane_details.trajectories ),[t,p,f], options);
    %errors{i} = errorfunc([t,p],[D,f], trajectories);
    ssd_errors(i) = sum(fval);
    if ~mod(i,50)
        fprintf('Completed %d of %d rows (%.3f%%)\n', i,length(inits),100*(i/length(inits)));
    end
end

[minerror,min_err_id] = min( ssd_errors );

E_theta = iter_result{min_err_id}(1);
E_psi   = iter_result{min_err_id}(2);
E_focal = iter_result{min_err_id}(3);

% fprintf('True (Theta, Psi, f) = ( %g, %g, %g )\n', GT_theta, GT_psi, GT_focal);
% fprintf('Best (Theta, Psi, f) = ( %g, %g, %g )\n', E_theta, E_psi, E_focal);

E_angles = [E_theta,E_psi];

% estParams = [thetas(best_combo_ids(1)),psis(best_combo_ids(2))];
% rectTraj = cellfun(@(x) backproj(estParams, exp_constants, x), trajectories, 'uniformoutput', false );
% rectPlane = backproj(estParams, exp_constants, imPlane ); 
% 
% DISTS = cellfun(@(x,y) vector_dist(x,y),rectTraj,traj2imc(camTraj,1,1),'uniformoutput',false);
end
