function [ssd_errors,best_combo_ids,minError,bestGuess,bestFoc] = iterator_parfor_foc( D, plane_details, thetas, psis,focals )

varStruct = plane_details;
struct2vars;

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

ssd_errors = ones( length(thetas), length( psis ) ) .* Inf;
errors = cell( length(thetas), length( psis ) ) ;
means = cell( length(thetas), length( psis ) ) ;
stds = cell( length(thetas), length( psis ) );

for t = 1:length(thetas)
    for p = 1:length(psis)
        for f = 1:length(focals)
            ang = [thetas(t),psis(p)];
            scl = [D, focals(f)];
        [angles{t,p},errors{t,p}] = fsolve(@(x) errorfunc(x(1:2),[D,x(3)], trajectories), ...
                                 [thetas(t),psis(p),focals(f)], ...
                                 options...
                                );
        ssd_errors(t,p) = sum(errors{t,p}.^2);
    end
    fprintf('Completed %d of %d thetas (%.3f%%)\n', t,length(thetas),100*(t/length(thetas)));
end

minError = min(min(ssd_errors));

[estTid, estPid] = find(minError == ssd_errors);
best_combo_ids = [estTid, estPid];

fprintf('True (Theta, Psi) = ( %g, %g )\n', GT_theta, GT_psi);
fprintf('Best (Theta, Psi) = ( %g, %g )\n', thetas(best_combo_ids(1)), psis(best_combo_ids(2)));

bestGuess = [thetas(best_combo_ids(1)), psis(best_combo_ids(2))];

estParams = [thetas(best_combo_ids(1)),psis(best_combo_ids(2))];
rectTraj = cellfun(@(x) backproj(estParams, exp_constants, x), trajectories, 'uniformoutput', false );
rectPlane = backproj(estParams, exp_constants, imPlane ); 

DISTS = cellfun(@(x,y) vector_dist(x,y),rectTraj,traj2imc(camTraj,1,1),'uniformoutput',false);

xs = zeros(numel(ssd_errors),1);
ys = zeros(numel(ssd_errors),1);
zs = zeros(numel(ssd_errors),1);
counter = 1;
for t=1:length(thetas)
    for p=1:length(thetas)
        xs(counter) = thetas(t);
        ys(counter) = psis(p);
        zs(counter) = ssd_errors(t,p);
        counter = counter + 1;
    end
end

scatter3( xs, ys, zs )
hold on;
plotCross([GT_theta,GT_psi,ssd_errors(find(thetas==GT_theta),find(psis==GT_psi))]);
xlabel('theta');
ylabel('psi');
zlabel('Function Error');
end
