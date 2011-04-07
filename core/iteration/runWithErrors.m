function [failReasons, x0s_mat, xiter_mat, pass] = ...
    runWithErrors( im_coords, H, im_ids, NUM_ITERS, num )
% Given a set of image points and the real-world homography, performs a
% single "run" of the algorithm, consisting of NUM_ITERS attempts.
%
%  INPUT:
%   im_coords    The set of image=-plane vectors
%   H            Homography from real-world
%   im_ids       Image coordinate ids used as input vectors
%   NUM_ITERS    Number of iterations (default: 1000)
%
%  OUTPUT:
%   failReasons  A matrix of reasons for attempt failure per iteration
%   x0s_mat      Matrix of initial conditions used for each iteration
%   xiter_mat    Matrix of output planes (in "iter" format) per iteration
%   pass         Column vector of passes/failure (1==pass) per iteration

if nargin < 3,
    NUM_ITERS = 1000;
end

options = optimset( 'Display', 'off', ...
                    'Algorithm', {'levenberg-marquardt',0.00001}, ...
                    'MaxFunEvals', 100000, ...
                    'MaxIter', 1000000, ...
                    'TolFun',1e-8, ...
                    'ScaleProblem','Jacobian' );
failReasons = zeros( NUM_ITERS, 5 );
x_iters     =  cell( NUM_ITERS, 1 );
x0s         =  cell( NUM_ITERS, 1 );
pass        = zeros( NUM_ITERS, 1 );


imc_use = im_coords(:,im_ids) ;
for i=1:NUM_ITERS,
    x0 = generateNormal();
    x0s{i} = x0;
    [ x_iter, ~, exitflag, ~ ] = fsolve( @gp_iter_func, x0, options, imc_use);
    
    x_iters{i} = x_iter;
   
    [validn,validd] = checkPlaneValidity( x_iter );
    
    wc = find_real_world_points( im_coords, iter2plane(x_iter) );
    baddist = checkDistributionFeasibility( wc, 5, 2 );
    
    f = notFit( im_coords, H, x_iter, 0.05 );

    %% checks
    fR = [ 0 0 0 0 0 ];
    % If we didn't converge
    if exitflag < 1,
        fR(1) = 1;
    end
    % If n is invalid
    if ~validn,
        fR(2) = 1;
    end
    % If d is invalid
    if ~validd,
        fR(3) = 1;
    end
    % If distribution is invalid
    if baddist,
        fR(4) = 1;
    end
    % If distribution doesn't match GT
    if f,
        fR(5) = 1;
    end
    %%
    
    failReasons(i,:) = fR;
    
    if sum(fR) == 0,
        pass(i) = 1;
    end
    fprintf('**********************************\nRun %04d, Attempt %04d\n*************************************\nPass: %d\n\n', num, i,pass(i));
    
end
xiter_mat=cell2mat(x_iters);

x0s_mat = cell2mat(x0s);

%% Save data    
fld = sprintf('errorRate/%s',getTodaysFolder( ) );
if ~exist(fld,'dir'),
    mkdir( fld );
end
a        = dir(sprintf('./%s/run*.mat',fld));
next_id  = size(a,1) + 1;

save( sprintf('%s/run_%03d.mat', fld, next_id) );
