% Given clean data, how far away can we start and still find happiness?

setup_exp;

%% Experiment Parameters
meanSpeed  = 3;
sdSpeed    = 0;
sdSpdInter = 0;
sdHeight   = 0;
sdDrn      = 15;


ls = 0.01:0.01:10;
ds = 0.1:0.1:10;

NUM_TRAJECTORIES = 1;
GT_T = 32;
GT_P = -16;
GT_D = 5;
GT_L = meanSpeed;

GT_N = normalFromAngle( GT_T,GT_P );
GT_ALPHA = 0.025;

GT_ITER = [n2abc(GT_N,GT_D)',GT_ALPHA];



[touse_grid, gridVars] = generateNormalSet_ls(GT_ALPHA,ds,GT_T,GT_P,ls);

 %% Generate Trajectories & Plane
basePlane = createPlane( GT_D, 0, 0, meanSpeed );
[baseTraj,~,~,trajSpeeds,trajHeights] = addTrajectoriesToPlane( basePlane, [], NUM_TRAJECTORIES, 2000, meanSpeed, sdSpeed, sdSpdInter, sdDrn, sdHeight);

rotX = makehgtform('xrotate',-deg2rad(GT_T));
rotZ = makehgtform('zrotate',-deg2rad(GT_P));
rotation = rotZ*rotX;

camPlane = rotation(1:3,1:3)*basePlane;
camTraj = cellfun(@(x) rotation(1:3,1:3)*x,baseTraj,'uniformoutput',false);

imPlane = wc2im(camPlane,GT_ALPHA);
imTraj = cellfun(@(x) traj2imc(wc2im(x,GT_ALPHA),1,1), camTraj,'uniformoutput',false);

pF = figure;
sp = subplot(1,2,1);
drawPlane( camPlane,'',0,'k' );
cellfun( @(x) drawcoords3(traj2imc(x,1,1),'',0,'k'),camTraj);
sp = subplot(1,2,2);
drawPlane( imPlane,'',0,'k' );
cellfun( @(x) drawcoords(x,'',0,'k'),imTraj);
saveas(pF, 'trajectory.fig');



%% Calculate Errors
err = Inf*ones(length(touse_grid),1);
if matlabpool('size') == 0 && (~exist('NOPOOL','var') || ~NOPOOL)
    matlabpool 3;
end
parfor x=1:length(touse_grid)
    err(x) = sum(traj_iter_func(touse_grid(x,:), imTraj,[],@traj_dist_eqn_ns_vn).^2);
end

GT_ERR = sum(traj_iter_func([GT_ITER,GT_L], imTraj,[],@traj_dist_eqn_ns_vn).^2);

if abs(log10(GT_ERR)) == Inf
    GT_ERR_DRAW = min(log10(err(log10(err) ~= -Inf)));
else
    GT_ERR_DRAW = log10(GT_ERR);
end


f = figure;
scatter3(gridVars(:,5),gridVars(:,4),log10(err), 24, 'b*');
ax = axis;
lim = [minmax(ls);minmax(ds);ax(5:6)];
hold on;
plotCross( [GT_L, GT_D, GT_ERR_DRAW], lim );
nullerr = find(~err);
for e=1:length(nullerr)
    plot3( repmat(gridVars(nullerr(e),5),1,2), repmat(gridVars(nullerr(e),4),1,2), ax(5:6) );
end
xlabel('l');
ylabel('d');
zlabel('Log Sum-Squared Diff Error, log_{10}(E)');
saveas(f, 'l_vs_error.fig');
save expdata_all.mat

