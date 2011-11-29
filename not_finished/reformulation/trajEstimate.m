NUM_NEEDED = 45;
fpath = input('File Path ([]=~/PhD/vids, <SIM>: Generate Simulated Data): ','s');

if strcmp( fpath, '<SIM>' )
    SIMULATED = 1;
  
    THETA = 15; PSI = 6; D = 10; FOC = 1/-250;

    [worldPlane,camPlane,rotation] = createPlane( D, THETA, PSI, 2 );
    [worldTraj,startframes, camTraj] = addTrajectoriesToPlane( worldPlane, rotation, 50, 2000, 1/5, 0 );
    trajectories = cellfun( @(x) wc2im(x, FOC), camTraj,'uniformoutput',false);
    imPlane = wc2im(camPlane,FOC);
    drawPlane( imPlane,'',1,'r' );
    cellfun(@(x) drawcoords(traj2imc(x,25,1),'',0,'k',1,''), trajectories);
    gf = getframe;
    frame = gf.cdata;

    N = normalFromAngle( 180-THETA, PSI );%
    fn = strcat('simulated_',datestr( now, 'HH-MM-SS' ));

else
    if isempty( fpath )
        fpath = '/home/csunix/sc06ijh/PhD/vids/';
    end

    fn = [];
    while isempty(fn)
        fn = input('File Name: ','s')
    end
    
    filename = strcat(fpath,'/',fn);
    [trajectories,frame] = lkrebuild(filename);
end


% % load pets_S2L3_v1 H
traj_im = cellfun( @(x) traj2imc(x, 25), trajectories, 'uniformoutput',false );
accept = filterTrajectories( traj_im, 5, 5 );

% Sample only horizontal vectors - doesn't account for yaw
%tobeoptimised_traj = accept(find( cellfun( @trajectoryAngle, accept ) < 45 ));

% Uniformly sub-sample trajectories over directions
trajAngles = cellfun( @trajectoryAngle, accept );
figs.roseFig = figure;rose(deg2rad(trajAngles),360)
tobeoptimised_traj = accept( subsampleByDrn( trajAngles, NUM_NEEDED ) );

% Uniform random sub-sample
% ids = randperm( length(accept) );
% tobeoptimised_traj = accept( ids(1:NUM_NEEDED) );
figs.overlayTraj = figure;
if ~SIMULATED
    imagesc(frame);
else
    drawPlane(imPlane, '', 0, 'r' );
end
cellfun(@(x) drawcoords(x,'',0,'b'), tobeoptimised_traj);

x0s = generateTrajectoryInitGrid( length(tobeoptimised_traj) );
err = Inf*ones(length(x0s),1);


disp('Building Error Vector');
tic
for x=1:length(x0s)
    err(x) = sum(traj_iter_func(x0s(x,:), tobeoptimised_traj).^2);
end
toc

[~,SIDS] = sort(err);

disp('Selecting x0s');
% Take the best 1% of initial conditions
tobeoptimised_x0 = x0s(SIDS(1:round(length(SIDS)*.1)),:);

fsolve_options;
x_iter      =  cell(size(tobeoptimised_x0,1),1);
fval        =  cell(size(tobeoptimised_x0,1),1);
exitflag    = zeros(size(tobeoptimised_x0,1),1);
output      =  cell(size(tobeoptimised_x0,1),1);


disp('Optimising');
t_outer = tic;
parfor b=1:length(tobeoptimised_x0)
    t_inner = tic;
    fprintf('\tInitial Estimate %d of %d\n',b, length(tobeoptimised_x0));
    [ x_iter{b}, fval{b}, exitflag(b), output{b} ] = fsolve(@(x) traj_iter_func(x, tobeoptimised_traj),tobeoptimised_x0(b,:),options);
    toc(t_inner)
end
toc(t_outer)

x_iters_good = x_iter(exitflag > 0);
errors = cellfun( @(x) sum(traj_iter_func(x,tobeoptimised_traj).^2), x_iters_good);
[~,MINIDX] = min(errors);
RESULT = x_iters_good{MINIDX};
 
if exist('H', 'var')
    gt_traj = cellfun(@(x) H*makeHomogenous(x), tobeoptimised_traj,'uniformoutput',false);
elseif exist('N','var') && exist('D','var')
    gt_traj = cellfun(@(x) find_real_world_points(x,iter2plane([N'./D,FOC])), tobeoptimised_traj,'uniformoutput',false);
    
else
    error('Not enough info for a ground-truth.')
end
est_traj = cellfun(@(x) find_real_world_points(x,iter2plane(x_iters_good{MINIDX}(1:4))), tobeoptimised_traj,'uniformoutput',false);


mu_gt  = findLengthDist( cell2mat(gt_traj),0);
mu_est = findLengthDist(cell2mat(est_traj),0);


gt_norm = cellfun( @(x) x ./ mu_gt, gt_traj,'uniformoutput',false);
est_norm = cellfun( @(x) x ./ mu_est, est_traj,'uniformoutput',false);
figs.trajVelocities = figure;
subplot(1,2,1);
bar(cellfun(@(x) mean(vector_dist(x)), est_norm));
title('Estimated Mean Trajectory Velocity Distribution');
subplot(1,2,2);
bar(cellfun(@(x) mean(vector_dist(x)), gt_norm));
title('GT Mean Trajectory Velocity Distribution');

figs.gt_plots = figure;
title('Using Closest Length Ratios')
subplot(1,2,1);
cellfun(@(x) drawcoords3( x./mu_gt, '', 0, 'k'), gt_traj );
title('Ground Truth Trajectories');
daspect([1 1 1])
s1dist = subplot(1,2,2);
findLengthDist(cell2mat(gt_traj)./mu_gt,2);
title('Velocity Distributions: GT rectification');
distax1 = axis;

figs.est_plots = figure;
subplot(1,2,1);
cellfun(@(x) drawcoords3( x./mu_est, '', 0, 'r'), est_traj );
title('Estimated Trajectories');
daspect([1 1 1])
s2dist = subplot(1,2,2);
findLengthDist(cell2mat(est_traj)./mu_est,2);
title('Velocity Distributions: Estimated rectification');
distax2 = axis;

axis([s1dist s2dist],interleave( min(distax1(1:2:end),distax2(1:2:end)), ...
                 max(distax1(2:2:end),distax2(2:2:end)) ));
fld = saveExpData( figs, 'uniform_drn_5vecs',fn );

save( strcat(fld,'/','alldata.mat') )
