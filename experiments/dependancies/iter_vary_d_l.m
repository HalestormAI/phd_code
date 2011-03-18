function [ iterations, completed, results ] = iter_vary_d_l( actual_d, actual_l, d_start, d_end, l_start, l_end, num_steps, im_coords, options )
%ITER_VARY_D Draws graphs showing the stability of the search-space
%   Enter no arguments for default values, or enter the non-starred args
%   Args:
%       actual_d    The correct value for 'd'
%       actual_l    The correct value for 'l'
%       d_start     Start point for inital d guesses
%       d_end       End point for initial d guesses
%       l_start     Start point for inital l guesses
%       l_end       End point for initial l guesses
%       d_step_size The distance between points when approximating d
%       l_step_size The distance between points when approximating l
%       im_coords*  A set of 8 2D image coordinates
%       options*     Options for fsolve
    
% If necessary, set up image coords
if nargin < 1 || nargin == 7,
    
    if nargin < 1,
        % Set up d, l etc
        actual_d = 5000;
        actual_l = 175;
        d_start = 0;
        d_end = 10000;
        l_start = 0;
        l_end = 350;
        num_steps = 25;
    end
    n = [0.05; sin(deg2rad(120)); cos(deg2rad(120)) ];      % Create a normal
    n_u = n ./ sqrt(n(1)^2 + n(2)^2 + n(3)^2);              % Make it a unit normal
    coords = make_angled_coords( n_u, actual_d, actual_l, 8 );     % Find world coordinates
    im_coords = image_coords_from_rw_and_plane( coords );   % Convert to image coordinates
    
elseif nargin > 0 && nargin < 8,
    error( 'Not enough arguments - give none to run with defaults, else see help' );
end
if nargin < 8,
    % Set up default options
    options = optimset( 'Display', 'off', 'Algorithm', {'levenberg-marquardt',.001}, 'MaxFunEvals', 100000, 'MaxIter', 1000000, 'TolFun',1e-10,'ScaleProblem','Jacobian' );
end


d_step_size = (actual_d*2) / num_steps
l_step_size = (actual_l*2) / num_steps

% init vars
num_tests   = (num_steps+1)^2;
iterations  = zeros(1,num_tests);
completed   = zeros(1,num_tests);
d_results     = zeros(1,size(d_start:d_step_size:d_end,2));
l_results     = zeros(1,size(l_start:l_step_size:l_end,2));
num = 1;
h = waitbar(0,'Starting...', 'Name', sprintf('Running %d iterations', num_tests) );


d_axis = zeros(1,num_tests);
l_axis = zeros(1,num_tests);

for x=1:num_steps,
    d_axis((x-1)*num_steps + 1 : x*num_steps) = d_start+(x-1)*d_step_size;
    for y=1:num_steps,
        pos = y+((x-1)*num_steps);
        l_axis(pos) = l_start+(y-1)*l_step_size;
    end
end

% Run the approximation for each initial d. l is fixed the correct value
for i=d_start:d_step_size:d_end,
  %  d_axis(num) = i
    for j=l_start:l_step_size:l_end,
        waitbar(num / num_tests, h, sprintf('Running Iteration: %d (%d%%)',num, round((num / num_tests) * 100)))
        x0 = [ i, j ];

        [ x, fval, exitflag, output ] = fsolve( @gp_iter_func, x0, options, im_coords );
        if exitflag < 1 || iscomplex( x(1) ) || iscomplex( x(2) ),
            completed(num) = 0;
        else
            completed(num) = 1;
        end

        iterations(num) = output.iterations;
        d_results(num) = x(1);
        l_results(num) = x(2);
        num = num+1;
    end
end
delete(h);

f = figure;
subplot(2,4,[1 2]);
%scatter( d_start:d_step_size:d_end, d_results .* completed, 'r*', 'SizeData', 1 );
hold on

size_la = size( l_axis )
size_da = size( d_axis )
size_lr = size( l_results )
size_dr = size( d_results )

scatter3( d_axis,l_axis, d_results, 'r*', 'SizeData', 6 );
mesh( d_axis, l_axis, actual_d .* ones(size(d_axis,2),size(l_axis,2)));
xlabel('Initial d');
ylabel('Initial l');
zlabel('Estimated d');
title(sprintf('Approximated d given varied inital guess (d: %3f, l: %3f)', actual_d, actual_l) );
view( 102,32);
hold off

subplot(2,4,[3 4]);
hold on
scatter3( d_axis,l_axis, l_results, 'r*', 'SizeData', 6 );
mesh( d_axis, l_axis, actual_l .* ones(size(d_axis,2),size(l_axis,2)));
xlabel('Initial d');
ylabel('Initial l');
zlabel('Estimated l');
title(sprintf('Approximated l given varied inital guess (d: %3f, l: %3f)', actual_d, actual_l) );
view( 102,32);
hold off


subplot(2,4,[5 6]);
scatter3( d_axis,l_axis, iterations, 'r*', 'SizeData', 6 );
xlabel('Initial d');
ylabel('Initial l');
zlabel('Num. Iterations');
title('Number of iterations required for convergence');

subplot(2,4,7);
scatter( d_axis, iterations, 'r*', 'SizeData', 6 );
xlabel('Initial d');
ylabel('Num. Iterations');
title('Number of iterations required for convergence for varied d');

subplot(2,4,8);
scatter( l_axis, iterations, 'r*', 'SizeData', 6 );
xlabel('Initial l');
ylabel('Num. Iterations');
title('Number of iterations required for convergence for varied l');

saveas(f,sprintf('vary_element_graphs/vary_d_and_l_d=%0.3f_l=%0.3f.fig', actual_d, actual_l),'fig');
saveas(f,sprintf('vary_element_graphs/vary_d_and_l_d=%0.3f_l=%0.3f.jpg', actual_d, actual_l),'jpg');

end

