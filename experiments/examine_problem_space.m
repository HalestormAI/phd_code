
%% Select Fixed Variables

setup_exp;

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

%% Calculate Errors
err = Inf*ones(length(touse_grid),1);
if matlabpool('size') == 0 && (~exist('NOPOOL','var') || ~NOPOOL)
    matlabpool 3;
end
parfor x=1:length(touse_grid)
    err(x) = sum(ERROR_FUNC([touse_grid(x,:),1], imTraj).^2);
end

GT_ERR = sum(ERROR_FUNC([GT_ITER,1], imTraj).^2);

DRAW_ALPHAS = -log10(abs(ALPHAS));
DRAW_GT_ALPHA = -log10(abs(GT_ALPHA));
%% Plot
if FIXED_VARS == 1
    % FIXED D and F
    lim = [minmax(THETAS);minmax(PSIS);log10(minmax(err'))];

%     f = figure;
    scatter3(touse_gridVars(:,1),touse_gridVars(:,2),log10(err), 24, MARKER_COLOUR);
    plotCross( [GT_T, GT_P, log10(GT_ERR)], lim );
    xlabel('Theta (Degrees)');
    ylabel('Psi (Degrees)');
elseif FIXED_VARS == 2
    % FIXED Theta and D
    lim = [minmax(PSIS);minmax(DRAW_ALPHAS);log10(minmax(err'))];

%     f = figure;
    scatter3(touse_gridVars(:,2),(-log10(abs(touse_gridVars(:,3)))),log10(err), 24, MARKER_COLOUR);
    plotCross( [GT_P, DRAW_GT_ALPHA, log10(GT_ERR)], lim );
    xlabel('Psi (degrees)');
    ylabel('f');
elseif FIXED_VARS == 3
    % FIXED Theta and F
    lim = [minmax(PSIS);minmax(DS);log10(minmax(err'))];

%     f = figure;
    scatter3(touse_gridVars(:,2),touse_gridVars(:,4),log10(err), 24, MARKER_COLOUR);
    plotCross( [GT_P, GT_D, log10(GT_ERR)], lim );
    xlabel('Psi (Degrees)');
    ylabel('d');
elseif FIXED_VARS == 4
    % FIXED Theta and Psi
    lim = [minmax(DRAW_ALPHAS);minmax(DS);log10(minmax(err'))];
    
%     f = figure;
    scatter3(-log10(abs(touse_gridVars(:,3))),touse_gridVars(:,4),log10(err), 24, MARKER_COLOUR);
    plotCross( [DRAW_GT_ALPHA, GT_D, log10(GT_ERR)], lim );
    xlabel('f)');
    ylabel('d');
elseif FIXED_VARS == 5
    % FIXED Psi and F
    lim = [minmax(THETAS);minmax(DS);log10(minmax(err'))];
    
%     f = figure;
    scatter3(touse_gridVars(:,1),touse_gridVars(:,4),log10(err), 24, MARKER_COLOUR);
    plotCross( [GT_T, GT_D, log10(GT_ERR)], lim );
    xlabel('Psi (Degrees)');
    ylabel('d');
elseif FIXED_VARS == 6
    % FIXED Psi and D
    lim = [minmax(THETAS);minmax(ALPHAS);log10(minmax(err'))];
    
%     f = figure;
    scatter3(touse_gridVars(:,1),-log10(abs(touse_gridVars(:,3))),log10(err), 24, MARKER_COLOUR);
    plotCross( [GT_T, DRAW_GT_ALPHA, log10(GT_ERR)], lim );
    xlabel('Theta (Degrees)');
    ylabel('f');
end
view(-41,12);
    zlabel('Log Sum-Squared Diff Error, log_{10}(E)');



%% Save data
save expdata;
% saveas(f, 'error_plot.fig');
cd ../;