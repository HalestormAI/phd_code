
% [trajectories,frame] = lkrebuild('/home/csunix/sc06ijh/PhD/vids/students003.avi');
% traj_im = cellfun( @(x) traj2imc(x, 25), trajectories, 'uniformoutput',false );
% accept = filterTrajectories( traj_im, 10, 4 );

err = Inf*ones(length(x0s),1);

% Find trajectories which are generally more vertical than horizontal
tobeoptimised_traj = accept(find( cellfun( @trajectoryAngle, accept ) < 45 ));
x0s = generateTrajectoryInitGrid( length(tobeoptimised_traj) );

disp('Building Error Vector');
tic
for x=1:length(x0s)
    err(x) = sum(traj_iter_func(x0s(x,:), tobeoptimised_traj).^2);
end
toc

[~,SIDS] = sort(err);

disp('Selecting x0s');
% Take the best 1% of initial conditions
tobeoptimised_x0 = x0s(SIDS(1:round(length(SIDS)*.01)),:);

fsolve_options;
x_iter      =  cell(size(tobeoptimised_x0,1),1);
fval        =  cell(size(tobeoptimised_x0,1),1);
exitflag    = zeros(size(tobeoptimised_x0,1),1);
output      =  cell(size(tobeoptimised_x0,1),1);


disp('Optimising');
t_outer = tic;
for b=1:length(tobeoptimised_x0)
    t_inner = tic;
    fprintf('\tInitial Estimate %d\n',b);
    [ x_iter{b}, fval{b}, exitflag(b), output{b} ] = fsolve(@(x) traj_iter_func(x, tobeoptimised_traj),tobeoptimised_x0(b,:),options);
    toc(t_inner)
end
toc(t_outer)