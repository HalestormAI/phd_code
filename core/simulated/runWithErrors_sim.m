function [failReasons, x0s_mat, xiter_mat, pass] = ...
    runWithErrors_sim( im_coords, im_ids, im1, NUM_ITERS, num )
% Given a set of image points and the real-world homography, performs a
% single "run" of the algorithm, consisting of NUM_ITERS attempts.
%
%  INPUT:
%   im_coords    The set of image=-plane vectors
%   im_ids       Image coordinate ids used as input vectors
%   im1          Frame snapshot (or equivalent vector: length(im1))
%   NUM_ITERS    Number of iterations (default: 1000)
%   num          Run number
%
%  OUTPUT:
%   failReasons  A matrix of reasons for attempt failure per iteration
%   x0s_mat      Matrix of initial conditions used for each iteration
%   xiter_mat    Matrix of output planes (in "iter" format) per iteration
%   pass         Column vector of passes/failure (1==pass) per iteration

if nargin < 3,
    NUM_ITERS = 1000;
end

global lmcalls;

options = optimset( 'Display', 'off', ...
                    'Algorithm',{'levenberg-marquardt',0.0001}, ...
                    'MaxFunEvals', 100000, ...
                    'MaxIter', 1000000, ...
                    'TolFun',1e-3, ...
                    'ScaleProblem','Jacobian' );
failReasons = zeros( NUM_ITERS, 4 );
x_iters     =  cell( NUM_ITERS, 1 );
x0s         =  cell( NUM_ITERS, 1 );
pass        = zeros( NUM_ITERS, 1 );


imc_use = im_coords(:,im_ids) ;
for i=1:NUM_ITERS,
    x0 = generateNormal(im1);
    x0s{i} = x0;
    try
        [ x_iter, fval, exitflag, ~ ] = fsolve( @gp_iter_func, x0, options, imc_use);
%         fval
        if ~exist('lmcalls','var'),
            lmcalls = 1;
        else
            lmcalls = lmcalls + 1;
        end
%         nFactor = norm(x_iter(2:4));
%         x_iter = [x_iter(1), x_iter(2:4)] vc;
        x_iters{i}     = x_iter;
        plane = iter2plane(x_iter);
        [validn,validalpha] = checkPlaneValidity( plane );

        wc = find_real_world_points( im_coords, plane );
        baddist = checkDistributionFeasibility( wc, 10, 1 );

%         f = notFit( im_coords, H, plane, 0.05 );

        %% checks
        fR = [ 0 0 0 0 ];
        % If we didn't converge
        if exitflag < 1,
            fR(1) = 1;
        end
        % If n is invalid
        if ~validn,
            fR(2) = 1;
        end
        % If d is invalid
        if ~validalpha,
            fR(3) = 1;
        end
        % If distribution is invalid
        if baddist,
            fR(4) = 1;
        end
       
    catch err,
        if strcmp(err.identifier, 'IJH:ITERATE:IMAGINARY'),
            fR = [ 1 0 0 0 ]
            x_iters{i} = [NaN,NaN,NaN,NaN];
        else
            rethrow(err);
        end
    end
    %%
    
    failReasons(i,:) = fR;
    
%     if sum(fR) == 0,
%         pass(i) = 1;
%     end
pass(i) = exitflag;
if num > 0,
    fprintf('**********************************\nRun %04d, Attempt %04d\n*************************************\nPass: %d\n\n', num, i,pass(i));
end
    
end

% Convert cells to mat
xiter_mat     = cell2mat(x_iters);

x0s_mat = cell2mat(x0s);

%% Save data    
fld = sprintf('multiplanar_sim/%s',getTodaysFolder( ) );
if ~exist(fld,'dir'),
    mkdir( fld );
end
a        = dir(sprintf('./%s/run*.mat',fld));
next_id  = size(a,1) + 1;

save( sprintf('%s/run_%03d.mat', fld, next_id) );