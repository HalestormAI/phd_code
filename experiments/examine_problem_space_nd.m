%% Set up experiment
ALPHAS = -10.^(-3:0.1:-1);
THETAS = 2:2:90;
PSIS   = -60:2:60;
DS = 1:1:20;

if exist('fine_grid.mat','file')
   load fine_grid grid gridVars;
else
    [grid,gridVars] = generateNormalSet_nd( ALPHAS,DS,THETAS,PSIS );
    save fine_grid grid gridVars
end

setup_exp;

NUM_TRAJECTORIES = 1;
GT_T = 32;
GT_P = -16;
GT_D = 18;

GT_N = normalFromAngle( GT_T,GT_P );
GT_ALPHA = ALPHAS(2);
GT_ITER = [GT_N',GT_D,GT_ALPHA];

% ****************************************************
% ****************************************************
% **                                                **
% **     REMEMBER TO CHANGE PLOTTING MECHANISM      **
% **                                                **
% ****************************************************
% ****************************************************


if FIXED_VARS == 1
    % Fixing f and d
    FIXED = intersect( find(gridVars(:,3) == GT_ALPHA), find(gridVars(:,4) == GT_D) );
elseif FIXED_VARS == 2
    % Fix theta and d
    FIXED = intersect( find(gridVars(:,1) == GT_T), find(gridVars(:,4) == GT_D) );
elseif FIXED_VARS == 3
% Fix theta and f
	FIXED = intersect( find(gridVars(:,1) == GT_T), find(gridVars(:,3) == GT_ALPHA) );
elseif FIXED_VARS == 4
% Fix theta and psi
	FIXED = intersect( find(gridVars(:,1) == GT_T), find(gridVars(:,2) == GT_P) );
elseif FIXED_VARS == 5
% Fix psi and f
	FIXED = intersect( find(gridVars(:,2) == GT_P), find(gridVars(:,3) == GT_ALPHA) );
elseif FIXED_VARS == 6
% Fix psi and d
    FIXED = intersect( find(gridVars(:,2) == GT_P), find(gridVars(:,4) == GT_D) );
end

touse_grid = grid(FIXED,:);
touse_gridVars = gridVars(FIXED,:);

%% Generate Trajectories & Plane
basePlane = createPlane( GT_D, 0, 0, 1 );
baseTraj = addTrajectoriesToPlane( basePlane, [], NUM_TRAJECTORIES, 2000, 1, 0, 0, 15);

rotX = makehgtform('xrotate',-deg2rad(GT_T));
rotZ = makehgtform('zrotate',-deg2rad(GT_P));
rotation = rotZ*rotX;

camPlane = rotation(1:3,1:3)*basePlane;
camTraj = cellfun(@(x) rotation(1:3,1:3)*x,baseTraj,'uniformoutput',false);

imPlane = wc2im(camPlane,GT_ALPHA);
imTraj = cellfun(@(x) traj2imc(wc2im(x,GT_ALPHA),1,1), camTraj,'uniformoutput',false);

pF = drawPlane( imPlane );
cellfun( @(x) drawcoords(x,'',0,'k'),imTraj);
saveas(pF, 'trajectory.fig');
% Calculate Errors
err = Inf*ones(length(touse_grid),1);
if matlabpool('size') == 0 && (~exist('NOPOOL','var') || ~NOPOOL)
    matlabpool 3;
end
parfor x=1:length(touse_grid)
    err(x) = sum(traj_iter_func_nd([touse_grid(x,:),1], imTraj).^2);
end

GT_ERR = sum(traj_iter_func_nd([GT_ITER,1], imTraj).^2);

%% Plot

if FIXED_VARS == 1
    % FIXED D and F
    lim = [minmax(THETAS);minmax(PSIS);log10(minmax(err'))];

    f = figure;
    scatter3(touse_gridVars(:,1),touse_gridVars(:,2),log10(err));
    plotCross( [GT_T, GT_P, log10(GT_ERR)], lim );
    xlabel('Theta (Degrees)');
    ylabel('Psi (Degrees)');
    zlabel('Log Sum-Squared Diff Error, log_{10}(E)');
elseif FIXED_VARS == 2
    % FIXED Theta and D
    lim = [minmax(PSIS);minmax(ALPHAS);log10(minmax(err'))];

    f = figure;
    scatter3(touse_gridVars(:,2),(touse_gridVars(:,3)),log10(err));
    plotCross( [GT_P, GT_ALPHA, log10(GT_ERR)], lim );
    xlabel('Psi (degrees)');
    ylabel('f');
    zlabel('Log Sum-Squared Diff Error, log_{10}(E)');
elseif FIXED_VARS == 3
    % FIXED Theta and F
    lim = [minmax(PSIS);minmax(DS);log10(minmax(err'))];

    f = figure;
    scatter3(touse_gridVars(:,2),touse_gridVars(:,4),log10(err));
    plotCross( [GT_P, GT_D, log10(GT_ERR)], lim );
    xlabel('Psi (Degrees)');
    ylabel('d');
    zlabel('Log Sum-Squared Diff Error, log_{10}(E)');
elseif FIXED_VARS == 4
    % FIXED Theta and Psi
    lim = [minmax(ALPHAS);minmax(DS);log10(minmax(err'))];
    
    f = figure;
    scatter3(touse_gridVars(:,3),touse_gridVars(:,4),log10(err));
    plotCross( [GT_ALPHA, GT_D, log10(GT_ERR)], lim );
    xlabel('Theta (Degrees)');
    ylabel('Psi (Degrees)');
    zlabel('Log Sum-Squared Diff Error, log_{10}(E)');
elseif FIXED_VARS == 5
    % FIXED Psi and F
    lim = [minmax(THETAS);minmax(DS);log10(minmax(err'))];
    
    f = figure;
    scatter3(touse_gridVars(:,1),touse_gridVars(:,4),log10(err));
    plotCross( [GT_T, GT_D, log10(GT_ERR)], lim );
    xlabel('Psi (Degrees)');
    ylabel('d');
    zlabel('Log Sum-Squared Diff Error, log_{10}(E)');
elseif FIXED_VARS == 6
    % FIXED Psi and D
    lim = [minmax(THETAS);minmax(ALPHAS);log10(minmax(err'))];
    
    f = figure;
    scatter3(touse_gridVars(:,1),touse_gridVars(:,3),log10(err));
    plotCross( [GT_T, GT_ALPHA, log10(GT_ERR)], lim );
    xlabel('Theta (Degrees)');
    ylabel('f');
    zlabel('Log Sum-Squared Diff Error, log_{10}(E)');
end



%% Save data
save expdata;
saveas(f, 'error_plot.fig');
cd ../;