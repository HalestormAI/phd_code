NUM_TRAJECTORIES = 20;
%{

load students003;

allTrajectories = recentreImageTrajectories( imTraj, frame );
imPlane = minmax2plane( minmax([allTrajectories{:}]) );

trajLengths = cellfun(@length, allTrajectories);
[~,sortedLengthIds] = sort(trajLengths,'descend');

trajectories = allTrajectories(sortedLengthIds(1:NUM_TRAJECTORIES));

camPlane = H*makeHomogenous(imPlane);
camTraj = cellfun(@(x) H*makeHomogenous(x), trajectories, 'uniformoutput', false );

[GT_N, GT_D] = planeFromPoints( [camTraj{:}], min(100,length([camTraj{:}])) );
%}
[GT_angles] = anglesFromN( GT_N, 1, 'degrees' );
GT_theta = GT_angles(1);
GT_psi = GT_angles(2);

setup_exp;

constants = [1,.1];

f = figure;
subplot(1,3,1);
drawPlane(imPlane,'',0);
drawcoords(trajectories,'',0,'k');
view(0,90);
subplot(1,3,2);
drawPlane(camPlane,'',0);
drawcoords3(traj2imc(camTraj,1,1),'',0);
%return;

thetas = 1:90;
psis = -60:60;

ssd_errors = ones( length(thetas), length( psis ) ) .* Inf;
errors = cell( length(thetas), length( psis ) ) ;
means = cell( length(thetas), length( psis ) ) ;
stds = cell( length(thetas), length( psis ) );

for t = 1:length(thetas)
    for p = 1:length(psis)
        [errors{t,p},means{t,p},stds{t,p}] = errorfunc( [thetas(t),psis(p)], constants, trajectories );
        ssd_errors(t,p) = sum(errors{t,p}.^2);
    end
    fprintf('Completed %d of %d thetas (%.3f%%)\n', t,length(thetas),100*(t/length(thetas)));
end

[estTid, estPid] = find(min(min(ssd_errors)) == ssd_errors);
best_combo_ids = [estTid, estPid];

fprintf('True (Theta, Psi) = ( %g, %g )\n', GT_theta, GT_psi);
fprintf('Best (Theta, Psi) = ( %g, %g )\n', thetas(best_combo_ids(1)), psis(best_combo_ids(2)));

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

estParams = [thetas(best_combo_ids(1)),psis(best_combo_ids(2))];
rectTraj = cellfun(@(x) backproj(estParams, constants, x), trajectories, 'uniformoutput', false );
rectPlane = backproj(estParams, constants, imPlane ); 
figure(f);
subplot(1,3,3);
drawPlane(rectPlane,'',0,'r');
drawcoords3(rectTraj,'',0,'r');
axis auto;

f2 = figure;
scatter3( xs, ys, zs )
plotCross([GT_theta,GT_psi,ssd_errors(find(thetas==GT_theta),find(psis==GT_psi))]);
xlabel('theta');
ylabel('psi');
zlabel('Function Error');

DISTS = cellfun(@(x,y) vector_dist(x,y),rectTraj,camTraj,'uniformoutput',false);
cellfun(@mean,DISTS)
cellfun(@std,DISTS)

saveas(f,'trajectories');
saveas(f2,'error_scatter');
save alldata;
