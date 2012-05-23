function [ssd_errors, plane_details] = iterator_parfor( exp_constants, plane_details )
% needs sortign out, get rid of FIG and SAVE stuff
if nargin < 2


    % get rid of this guff
    D = 10;
    FOC = 1;

    GT_theta = 13;
    GT_psi = -37;

    params = [GT_theta, GT_psi];
    constants = [D,FOC];

    stddev = 0.1;
    stddev_w = 0;

    [worldPlane, camPlane, imPlane, rot] = createCameraPlane( params, constants, 10 );
    [worldTraj,~,camTraj] = addTrajectoriesToPlane( worldPlane, rot, 20, 5000, 1, stddev, stddev_w); 
    imPlane = wc2im( camPlane, FOC );
    trajectories = cellfun(@(x) traj2imc(wc2im(x,FOC),1,1), camTraj, 'uniformoutput', false );

%% Write this function    plane_details = createPlaneDetails( params, constants );
%% Write this function,    structToVarsi

end


tpl = 'std_w=%g,std=%g,t=%d,p=%g,d=%g,f=%g__%s';
expdir = sprintf(tpl, stddev_w, stddev, GT_theta, GT_psi, D, FOC, datestr(now(), 'HH-MM-SS'));
if ~exist('NOSAVE','var')
    setup_exp;
end

if ~exist('NOFIG','var')
    f = figure;
    subplot(1,3,1);
    drawPlane(imPlane,'',0);
    drawcoords(trajectories,'',0,'k');
    view(0,90);
    subplot(1,3,2);
    drawPlane(camPlane,'',0);
    drawcoords3(traj2imc(camTraj,1,1),'',0);
end%return;

thetas = 1:90;
psis = -60:60;

ssd_errors = ones( length(thetas), length( psis ) ) .* Inf;
errors = cell( length(thetas), length( psis ) ) ;
means = cell( length(thetas), length( psis ) ) ;
stds = cell( length(thetas), length( psis ) );

for t = 1:length(thetas)
    for p = 1:length(psis)
        [errors{t,p},means{t,p},stds{t,p}] = errorfunc( [thetas(t),psis(p)], exp_constants, trajectories );
        ssd_errors(t,p) = sum(errors{t,p}.^2);
    end
    fprintf('Completed %d of %d thetas (%.3f%%)\n', t,length(thetas),100*(t/length(thetas)));
end

[estTid, estPid] = find(min(min(ssd_errors)) == ssd_errors);
best_combo_ids = [estTid, estPid];

fprintf('True (Theta, Psi) = ( %g, %g )\n', GT_theta, GT_psi);
fprintf('Best (Theta, Psi) = ( %g, %g )\n', thetas(best_combo_ids(1)), psis(best_combo_ids(2)));

estParams = [thetas(best_combo_ids(1)),psis(best_combo_ids(2))];
rectTraj = cellfun(@(x) backproj(estParams, exp_constants, x), trajectories, 'uniformoutput', false );
rectPlane = backproj(estParams, exp_constants, imPlane ); 

if ~exist('NOFIG','var')
    figure(f);
    subplot(1,3,3);
    drawPlane(rectPlane,'',0,'r');
    drawcoords3(rectTraj,'',0,'r');

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
    
    f2 = figure;
    scatter3( xs, ys, zs )
    plotCross([GT_theta,GT_psi,ssd_errors(find(thetas==GT_theta),find(psis==GT_psi))]);
    xlabel('theta');
    ylabel('psi');
    zlabel('Function Error');
end;

DISTS = cellfun(@(x,y) vector_dist(x,y),rectTraj,traj2imc(camTraj,1,1),'uniformoutput',false);
cellfun(@mean,DISTS)
cellfun(@std,DISTS)

if ~exist('NOSAVE','var')
    saveas(f,'trajectories');
    saveas(f2,'error_scatter');
    save alldata;
end
