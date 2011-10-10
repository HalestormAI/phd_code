clear;
clc;
close all;
PROPORTION = 5e-3;

params = struct('d',3,'theta',32, 'psi', 17, 'alpha', -1/720 );
[N_orig, C, C_im] = makeCleanVectors(params.theta, ...
params.psi, ...
params.d, ...
params.alpha, 100 );
ABC = N_orig./params.d;


grid = generateNormalSet( );

ids_full = smartSelection(C_im, 4, 1/3);
[failReasons, passiters, x_iters, pass] = runsForX0( C_im, ids_full, grid, 1, -1 );
griderrors = cell2mat( cellfun(@(x) sum(gp_iter_func(x,C_im).^2), num2cell(grid,2), 'UniformOutput',false ) );

exits = cell2mat(pass);

goodgrid = grid(exits > 0,:);
goodgriderrs = griderrors(exits > 0);

[~,sortedids] = sort(goodgriderrs);
best_few = sortedids(1:ceil(length(goodgriderrs)*PROPORTION));

ns = cell2mat(cellfun(@(x) x(1:3)/norm(x(1:3)), num2cell(goodgrid(best_few,:),2),'UniformOutput',false))

figure;scatter3(ns(:,1),ns(:,2),ns(:,3),24,goodgriderrs(best_few));
hold on;
axes_max = max(ns,[],1);
axes_min = min(ns,[],1);
l1 = plot3( [N_orig(1) N_orig(1)],[N_orig(2) N_orig(2)],[axes_min(3) axes_max(3)], 'm-' );
l2 = plot3( [N_orig(1) N_orig(1)],[axes_min(2) axes_max(2)],[N_orig(3) N_orig(3)], 'm-' );
l3 = plot3( [axes_min(1) axes_max(1)],[N_orig(2) N_orig(2)],[N_orig(3) N_orig(3)], 'm-' );
xlabel('n_x');ylabel('n_y');zlabel('n_z');

figure;scatter3(goodgrid(best_few,1),goodgrid(best_few,2),goodgrid(best_few,3),24,goodgriderrs(best_few));
hold on
axes_max = max(grid,[],1);
axes_min = min(grid,[],1);
l1 = plot3( [ABC(1) ABC(1)],[ABC(2) ABC(2)],[axes_min(3) axes_max(3)], 'm-' );
l2 = plot3( [ABC(1) ABC(1)],[axes_min(2) axes_max(2)],[ABC(3) ABC(3)], 'm-' );
l3 = plot3( [axes_min(1) axes_max(1)],[ABC(2) ABC(2)],[ABC(3) ABC(3)], 'm-' );
xlabel('a'),ylabel('b'),zlabel('c');

[pass2.failReasons, pass2.passiters, pass2.x_iters, pass2.pass] = runsForX0( C_im, cid2mpid(1:length(C_im)), goodgrid(best_few,:), 1, -1 );
cell2mat(pass2.x_iters)
ABC,params.alpha