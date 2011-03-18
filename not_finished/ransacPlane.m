function [final_x, x_iters, init_conds, angles ] = ransacPlane( im_coords, x_iters, Ns )

final_x = [0,0,0,0];
NUMTESTS = 100;

if nargin < 2,
    h = waitbar(0,'Starting...', 'Name', sprintf('%d iterations', NUMTESTS));
    x_iters = zeros( NUMTESTS, 4 );
    init_conds = zeros( NUMTESTS, 4 );
    x0 = [ 1   0.0525    0.0525    0.9972 ];
    for i=1:NUMTESTS,
        waitbar(i / NUMTESTS, h, sprintf('Running Iteration: %d (%d%%)',i, round(i / NUMTESTS * 100)));
        [ ~, x_iters(i,:), ~, ~, init_conds(i,:) ] = iterate_to_gp_video( im_coords,x0, 3, 'MONTECARLO', 0 );
    end
    delete(h);
end
FF  = find( abs(x_iters(:,1)) > 1);
NFF = find( ~(abs(x_iters(:,1)) > 1));

% Plot results in N space

figure,
scatter3( x_iters(NFF,2),x_iters(NFF,3),x_iters(NFF,4), '*r' )
hold on,
scatter3( x_iters(FF,2),x_iters(FF,3),x_iters(FF,4), 'g*' )
scatter3( Ns(:,1),Ns(:,2),Ns(:,3), 'm*' )
axis( [ -1 1 -1 1 -1 1] )

% Get angle errors from first N
CELL_n1   = num2cell( all_x_iters2( FF, 2:4 ), 2 );
angles_n1 = cellfun( @(x) angleError(x, Ns(1,1:3)), CELL_n1 );
% Get angle errors from second N
CELL_n2   = num2cell( all_x_iters2( FF, 2:4 ), 2 );
angles_n2 = cellfun( @(x) angleError(x, Ns(2,1:3)), CELL_n2 );

angles = cell(2,1);
angles{1} = angles_n1;
angles{2} = angles_n2;