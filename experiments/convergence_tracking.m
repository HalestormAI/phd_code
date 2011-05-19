clear,clc
params = struct('d',3,'theta',65, 'psi', 30, 'alpha', 1/720 );
N_orig = normalFromAngle( params.theta, params.psi );                                
myH = [params.d, N_orig', params.alpha];

[N,coords,im_coords] = makeCleanVectors( params.theta, params.psi, params.d, params.alpha,100 );

NUMEXPS = 20;

ids_full = smartSelection(im_coords, 3, 1/3);

[failReasons, x0s, xiters,pass] = ...
        runWithErrors(im_coords,myH,ids_full,1:720,NUMEXPS,0);
    
feasible   = find(~sum(failReasons(~failReasons(:,1),1:4),2));
infeasible = find( sum(failReasons(~failReasons(:,1),2:4),2));

correct    = find(~sum(failReasons(~failReasons(:,1),:),2));
incorrect  = find( failReasons(~failReasons(:,1),5),2);
% Make sure there's no overlap between incorrect and infeasible
[~,AI]=setxor(incorrect,infeasible);
incorrect = incorrect(AI);

xiters_full = xiters;
x0s_full    = xiters;
xiters = xiters(~failReasons(:,1),:);
x0s    =    x0s(~failReasons(:,1),:);


figure, hold on, grid on;
% Plot lines
g_c = hggroup
for i = 1:length(correct),
    l_c = plot3( [ xiters(correct(i),2) x0s(correct(i),2) ],...
                  [ xiters(correct(i),3) x0s(correct(i),3) ],...
                  [ xiters(correct(i),4) x0s(correct(i),4) ], 'g--o' );
    set(l_c, 'Parent', g_c )
end

g_ic = hggroup
for i = 1:length(incorrect),
l_ic = plot3( [ x0s(incorrect(i),2) xiters(incorrect(i),2) ],...
              [ x0s(incorrect(i),3) xiters(incorrect(i),3) ],...
              [ x0s(incorrect(i),4) xiters(incorrect(i),4) ], 'r--d' );
    set(l_ic, 'Parent', g_ic )
end
g_if = hggroup
for i = 1:length(infeasible),
l_if = plot3( [ x0s(infeasible(i),2) xiters(infeasible(i),2) ],...
              [ x0s(infeasible(i),3) xiters(infeasible(i),3) ],...
              [ x0s(infeasible(i),4) xiters(infeasible(i),4) ], 'k--s' );
    set(l_if, 'Parent', g_if )
end

% set(get(get(g_c,'Annotation'),'LegendInformation'),...
%      'IconDisplayStyle','on');
% set(get(get(g_ic,'Annotation'),'LegendInformation'),...
%  'IconDisplayStyle','on');
% set(get(get(g_if,'Annotation'),'LegendInformation'),...
%  'IconDisplayStyle','on');


% Plot convergence points
scatter3( x0s(correct,2),x0s(correct,3),x0s(correct,4),'go' )
scatter3( x0s(incorrect,2),x0s(incorrect,3),x0s(incorrect,4),'rd' )
scatter3( x0s(infeasible,2),x0s(infeasible,3),x0s(infeasible,4),'ks' )
scatter3( xiters(correct,2),xiters(correct,3),xiters(correct,4),'go', 'MarkerFaceColor', 'g' )
scatter3( xiters(incorrect,2),xiters(incorrect,3),xiters(incorrect,4),'rd', 'MarkerFaceColor', 'r' )
scatter3( xiters(infeasible,2),xiters(infeasible,3),xiters(infeasible,4),'ks', 'MarkerFaceColor', 'k' )

% Draw actual N
n_grp = hggroup;
l1 = plot3( [N_orig(1) N_orig(1)],[N_orig(2) N_orig(2)],[-1 1], 'm-' );
l2 = plot3( [N_orig(1) N_orig(1)],[-1 1],[N_orig(3) N_orig(3)], 'm-' );
l3 = plot3( [-1 1],[N_orig(2) N_orig(2)],[N_orig(3) N_orig(3)], 'm-' );
set(l1, 'Parent', n_grp )
set(l2, 'Parent', n_grp )
set(l3, 'Parent', n_grp )
set(get(get(n_grp,'Annotation'),'LegendInformation'),...
     'IconDisplayStyle','on');
    

 legend('Initial Points - Correct','Initial Points - Incorrect', ...
     'Initial Points - Infeasible','Convergence Points - Correct',...
     'Convergence Points - Incorrect', ...
     'Convergence Points - Infeasible','Ground Truth \bf{n}');

xlabel('nx');
ylabel('ny');
zlabel('nz');
