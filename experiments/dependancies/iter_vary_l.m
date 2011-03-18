function [ iterations, completed, results ] = iter_vary_l( actual_l, d, l_start, l_end, step_size, im_coords, options )
%ITER_VARY_L Draws graphs showing the stability of the search-space
%   Enter no arguments for default values, or enter the non-starred args
%   Args:
%       actual_l    The correct value for 'l'
%       d           The correct d
%       l_start     Start point for inital guesses
%       l_end       End point for initial guesses
%       step_size   The distance between points
%       im_coords*  A set of 8 2D image coordinates
%       options*     Options for fsolve
    
% If necessary, set up image coords
if nargin < 1 || nargin == 5,
    
    if nargin < 1,
        % Set up d, l etc
        actual_l = 175;
        d = 5000;
        l_start = 0;
        l_end = 10000;
        step_size = 2;
    end
    n = [0.05; sin(deg2rad(120)); cos(deg2rad(120)) ];      % Create a normal
    n_u = n ./ sqrt(n(1)^2 + n(2)^2 + n(3)^2);              % Make it a unit normal
    coords = make_angled_coords( n_u, d, actual_l, 8 );     % Find world coordinates
    im_coords = image_coords_from_rw_and_plane( coords );   % Convert to image coordinates
    
elseif nargin > 0 && nargin < 5,
    error( 'Not enough arguments - give none to run with defaults, else see help' );
end
if nargin < 7,
    % Set up default options
    options = optimset( 'Display', 'off', 'Algorithm', {'levenberg-marquardt',.001}, 'MaxFunEvals', 100000, 'MaxIter', 1000000, 'TolFun',1e-10,'ScaleProblem','Jacobian' );
end


% init vars
num_tests   = (l_end - l_start) / step_size;
iterations  = zeros(1,num_tests);
completed   = zeros(1,num_tests);
results     = zeros(1,num_tests);

num = 1;
h = waitbar(0,'Starting...');
% Run the approximation for each initial d. l is fixed the correct value
for i=l_start:step_size:l_end,
    waitbar(num / num_tests, h, sprintf('Running Iteration: %d (%d%%)',num, round((num / num_tests) * 100)))
    x0 = [ d, i ];
    
    [ x, fval, exitflag, output ] = fsolve( @gp_iter_func, x0, options, im_coords );
    if exitflag < 1 && ~iscomplex( x(1)),
        completed(num) = 0;
    else
        completed(num) = 1;
    end
    
    iterations(num) = output.iterations;
    results(num) = x(2);
    num = num+1;
end
delete(h);

figure
subplot(2,1,1);
scatter( l_start:step_size:l_end, results .* completed, 'r*', 'SizeData', 1 );
hold on
scatter( l_start:step_size:l_end, results, 'g*', 'SizeData', 2 );
line( l_start:step_size:l_end, actual_l );
xlabel('Initial l');
ylabel('Estimated l');
title(sprintf('Approximated l given varied inital guess (Actual: %f)', actual_l ));
hold off
subplot(2,1,2);
scatter(l_start:step_size:l_end, iterations, 'b*');
xlabel('Initial l');
ylabel('Num. Iterations');
title('Number of iterations required for convergence');


end

