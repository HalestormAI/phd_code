function [ iterations, completed, x ] = iter_vary_n( initial_n, actual_n, im_coords, d, options )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

if nargin < 5,
    error('Minimum 5 args.');
end
if nargin < 7,
    % Set up default options
    options = optimset( 'Display', 'off', 'Algorithm', {'levenberg-marquardt',.001}, 'MaxFunEvals', 100000, 'MaxIter', 1000000, 'TolFun',1e-10,'ScaleProblem','Jacobian' );
end




x0 = [ d, initial_n(1), initial_n(2), initial_n(3) ];
[ x, fval, exitflag, output ] = fsolve( @gp_iter_func, x0, options, im_coords );

if exitflag < 1 && ~iscomplex( x(1)),
    completed = 0;
else
    completed = 1;
end

iterations = output.iterations;


end

