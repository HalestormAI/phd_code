function [iters, initial_ns, results, completed, actual_n, correct_gp, im_coords] = vary_n_test_script( num_it, fixld )
%VARY_D_TEST_SCRIPT Summary of this function goes here
%   Detailed explanation goes here



%TODO: Need to alter S.T. non-feasible values of d and l (i.e. below 100,
% etc are recognised as erroneous as apposed to incorrect.



d = 5000; l = 175;
init_d = 5876; init_l = 210;

if nargin < 1,
    num_it = 300;
    fixld = 1;
elseif nargin < 2,
    fixld = 1;
end


initial_ns  = zeros(3,num_it);
iters       = zeros(1,num_it);
results     = zeros(3,num_it);
completed   = zeros(1,num_it);
ds         = zeros(1,num_it);

n = [0.05; sin(deg2rad(120)); cos(deg2rad(120)) ];      % Create a normal
actual_n = n ./ sqrt(n(1)^2 + n(2)^2 + n(3)^2);   
coords = make_angled_coords( actual_n, d, l, 8 );     % Find world coordinates
im_coords = image_coords_from_rw_and_plane( coords );   % Convert to image coordinates
h = waitbar(0,'Starting...', 'Name', sprintf('%d iterations', num_it));

for i=1:num_it,
    waitbar(i / num_it, h, sprintf('Running Iteration: %d (%d%%)',i, round((i / num_it) * 100)), 'Name')

    % Build random unit normal
    nx = rand(1)*0.1;
    ny = rand(1);
    nz = -rand(1);
    n = [ nx;ny;nz];
    initial_n = n ./ sqrt(n(1)^2 + n(2)^2 + n(3)^2);
    
    % Append to the set of initial n's
    initial_ns(:,i) = initial_n;
    
    % Perform approximation
    [ iter, comp, output ] = iter_vary_n( initial_n, actual_n, im_coords, init_d, init_l );

    % If l and d are fixed, just store the normal in the output
    if fixld == 1,
        results(:,i) = output';
    else
        % store ds and ns
        results(:,i) = output(2:4)';
        ds(1,i) = output(1);
    end
    
    iters(i)     = iter;
    completed(i) = comp;    
end

delete(h);

% Find any results that don't match the ||n|| = 1 restriction
erroneous_idx = find_wrong_n( results, 0.001, ds )
erroneous = results( : , erroneous_idx );
erroneous_ns = initial_ns( :, erroneous_idx );
e_iters = iters(erroneous_idx);
% The set of iterations that don't match ||n|| = 1
% The set of results that DO fit ||n|| = 1
feasible_idx = setxor( erroneous_idx, 1:size(results,2) )
feasible = results(:, feasible_idx );
feasible_ns = initial_ns(:, feasible_idx );
% Find results that converge to the exactly correct point (within tolerance)
c_idx = find_correct_approx_indices( feasible, actual_n, 100 ); % correct
w_idx = setxor( c_idx, 1:size(feasible_ns,2) ); % incorrect

correct_res = feasible( :, c_idx )
incorrect_res = feasible(:, w_idx ); % Valid but wrong N
correct_ns = feasible_ns(:, c_idx );
incorrect_ns = feasible_ns(:, w_idx ); % Valid but wrong N



% Get Ls and Ds that coincide with feasible n's
feasible_ds = ds(1,feasible_idx); % all d's that have a feasible n
correct_n_ds = feasible_ds(c_idx); % all d's that have a correct n
incorrect_feasible_ds = feasible_ds(w_idx); % Valid, wrong n
erroneous_ds = ds(:,erroneous_idx);
c_ds_idx = find_correct_ls( correct_n_ds, d / l ,10,(d / l)*0.1 );

% Find intersection of correct l's and d's
w_ds_idx = setxor( c_ds_idx, 1:size(correct_ns,2) );
correct_ds = correct_n_ds( c_ds_idx ) % all correct d's that are correct for n
incorrect_ds = [incorrect_feasible_ds, correct_n_ds( w_ds_idx ) ] ;

%{
Num_correct_ls = size(correct_ls,2)
Num_erroneous_ls = size(erroneous_ls,2)
Num_incorrect_ls = size(incorrect_ls,2)
Total_ls = Num_correct_ls + Num_incorrect_ls + Num_erroneous_ls
Num_correct_ds = size(correct_ds,2)
Num_erroneous_ds = size(erroneous_ds,2)
Num_incorrect_ds = size(incorrect_ds,2)
Total_ds = Num_correct_ds + Num_incorrect_ds + Num_erroneous_ds
%}


incorrect_ns = [ incorrect_ns(:,:), correct_ns(:,w_ds_idx) ];
incorrect_res = [ incorrect_res(:,:), correct_res(:,w_ds_idx) ];

% Output potentially ground plane equations
correct_gp = [ correct_ds(1,:) ; correct_res(:,c_ds_idx)  ]


figure;
% Plot all feasible initial points that give the correct result in green
scatter3( correct_ns(1,c_ds_idx),correct_ns(2,c_ds_idx),correct_ns(3,c_ds_idx), 'g*' );
hold on;
% Plot all feasible inital points that give the wrong result in black
scatter3( incorrect_ns(1,:), incorrect_ns(2,:), incorrect_ns(3,:), 'r*' );
% Plot all non-feasible initial points in red
scatter3( erroneous_ns(1,:), erroneous_ns(2,:), erroneous_ns(3,:), 'k*' );
% Plot feasible, correct convergence points in green
scatter3( correct_res(1,c_ds_idx),correct_res(2,c_ds_idx),correct_res(3,c_ds_idx), 'go' );
% Plot feasible, incorrect convergence points in black
scatter3( incorrect_res(1,:), incorrect_res(2,:), incorrect_res(3,:), 'ro' );
% Plot non-feasible convergence points in red
scatter3( erroneous(1,:), erroneous(2,:), erroneous(3,:), 'ko' );

% Plot convergence for correct results in green, incorrect in blue, non-feasible in black
finitc_grp = hggroup;
finitw_grp = hggroup;
nfinit_grp = hggroup;
finit_correct = plot3( [ correct_ns( 1,c_ds_idx); correct_res(1,c_ds_idx) ],[ correct_ns( 2,c_ds_idx); correct_res(2,c_ds_idx) ],[ correct_ns( 3,c_ds_idx); correct_res(3,c_ds_idx) ], 'g-' );
finit_wrong   = plot3( [ incorrect_ns( 1,:); incorrect_res(1,:) ],[ incorrect_ns( 2,:); incorrect_res(2,:) ],[ incorrect_ns( 3,:); incorrect_res(3,:) ], 'r:' );
nfinit        = plot3( [ erroneous_ns( 1,: )  ; erroneous( 1,: )  ],[ erroneous_ns( 2,: )  ; erroneous( 2,: )  ],[ erroneous_ns( 3,: )  ; erroneous(3,:)    ], 'k:' );

set(finit_correct,'Parent',finitc_grp)
set(finit_wrong  ,'Parent',finitw_grp)
set(nfinit       ,'Parent',nfinit_grp)

% Plot Actual n.
scatter3( actual_n(1), actual_n(2), actual_n(3), 'm*' );
minm = [ min([initial_ns(1,:),results(1,:)]); min([initial_ns(2,:),results(2,:)]); min([initial_ns(3,:),results(3,:)]) ];
maxm = [ max([initial_ns(1,:),results(1,:)]); max([initial_ns(2,:),results(2,:)]); max([initial_ns(3,:),results(3,:)]) ];
axesgrp = hggroup;

axes1 = plot3( [minm(1), maxm(1)],         [actual_n(2), actual_n(2)], [actual_n(3), actual_n(3)], 'm--' );
axes2 = plot3( [actual_n(1), actual_n(1)], [minm(2), maxm(2)],         [actual_n(3), actual_n(3)], 'm--' );
axes3 = plot3( [actual_n(1), actual_n(1)], [actual_n(2), actual_n(2)], [minm(3), maxm(3)],         'm--' );

set(axes1,'Parent',axesgrp)
set(axes2,'Parent',axesgrp)
set(axes3,'Parent',axesgrp)

xlabel('nx');ylabel('ny');zlabel('nz');
title('Feasible and Correct Values of n, including L and D');


set(get(get(finitc_grp,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
set(get(get(finitw_grp,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
set(get(get(nfinit_grp,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
set(get(get(axesgrp   ,'Annotation'),'LegendInformation'),'IconDisplayStyle','on');

legend( 'Feasible, correct initial', 'Feasible, incorrect initial', 'Non-feasible initial', 'Feasible, correct convergence', 'Feasible, incorrect convergence', 'Non-feasible convergence' );



figure,
% Plot correct, feasible l's in green
scatter3(correct_ns(1,c_ds_idx), correct_ns(2,c_ds_idx), correct_ds(1,:), 'go' );
hold on;
scatter3(incorrect_ns(1,:), incorrect_ns(2,:), incorrect_ds(1,:), 'ro' );
scatter3(erroneous_ns(1,:), erroneous_ns(2,:), erroneous_ds(1,:), 'ko' );
%mesh( initial_ns(1,:), initial_ns(2,:), d .* ones(size(initial_ns,2),size(initial_ns,2)));
mesh( initial_ns(1,:), initial_ns(2,:), (d / l) .* ones(size(initial_ns,2),size(initial_ns,2)));
xlabel('Initial nx');
ylabel('Initial ny');
zlabel('Estimated l');
title('Estimated d/l given initial nx and ny');

return
