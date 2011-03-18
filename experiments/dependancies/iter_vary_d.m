function [ iterations, completed, results ] = iter_vary_d( actual_d, l, d_start, d_end, step_size, im_coords, options )
%ITER_VARY_D Draws graphs showing the stability of the search-space
%   Enter no arguments for default values, or enter the non-starred args
%   Args:
%       actual_d    The correct value for 'd'
%       l           The correct length
%       d_start     Start point for inital guesses
%       d_end       End point for initial guesses
%       step_size   The distance between points
%       im_coords*  A set of 8 2D image coordinates
%       options*     Options for fsolve
    
% If necessary, set up image coords
if nargin < 1 || nargin == 5,
    
    if nargin < 1,
        % Set up d, l etc
        actual_d = 5000;
        l = 175;
        d_start = 0;
        d_end = 10000;
        step_size = 2;
    end
    n = [0.05; sin(deg2rad(120)); cos(deg2rad(120)) ];      % Create a normal
    n_u = n ./ sqrt(n(1)^2 + n(2)^2 + n(3)^2);              % Make it a unit normal
    coords = make_angled_coords( n_u, actual_d, l, 8 );     % Find world coordinates
    im_coords = image_coords_from_rw_and_plane( coords );   % Convert to image coordinates
    
elseif nargin > 0 && nargin < 5,
    error( 'Not enough arguments - give none to run with defaults, else see help' );
end
if nargin < 7,
    % Set up default options
    options = optimset( 'Display', 'off', 'Algorithm', {'levenberg-marquardt',.001}, 'MaxFunEvals', 100000, 'MaxIter', 1000000, 'TolFun',1e-10,'ScaleProblem','Jacobian' );
end


% init vars
num_tests   = (d_end - d_start) / step_size;
iterations  = zeros(1,num_tests);
completed   = zeros(1,num_tests);
results     = zeros(1,num_tests);

num = 1;
h = waitbar(0,'Starting...');
% Run the approximation for each initial d. l is fixed the correct value
for i=d_start:step_size:d_end,
    waitbar(num / num_tests, h, sprintf('Running Iteration: %d (%d%%)',num, round((num / num_tests) * 100)))
    x0 = [ i, l ];
    
    [ x, fval, exitflag, output ] = fsolve( @gp_iter_func, x0, options, im_coords );
    if exitflag < 1 && ~iscomplex( x(1)),
        completed(num) = 0;
    else
        completed(num) = 1;
    end
    
    iterations(num) = output.iterations;
    results(num) = x(1);
    num = num+1;
end
delete(h);

figure
subplot(2,1,1);
scatter( d_start:step_size:d_end, results .* completed, 'r*', 'SizeData', 1 );
hold on
scatter( d_start:step_size:d_end, results, 'g*', 'SizeData', 2 );
line( d_start:step_size:d_end, actual_d );
xlabel('Initial d');
ylabel('Estimated d');
title(sprintf('Approximated d given varied inital guess (d: %3f)', actual_d) );
hold off
subplot(2,1,2);
scatter(d_start:step_size:d_end, iterations, 'b*');
xlabel('Initial d');
ylabel('Num. Iterations');
title('Number of iterations required for convergence');


end

