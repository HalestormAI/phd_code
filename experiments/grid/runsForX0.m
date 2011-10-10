function [failReasons, passiters, x_iters, pass] = ...
    runsForX0( im_coords, im_ids, x0s, NUM_ITERS, num )
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


options = optimset( 'Display', 'off', ...
                    'Algorithm',{'levenberg-marquardt',0.0001}, ...
                    'MaxFunEvals', 100000, ...
                    'MaxIter', 1000000, ...
                    'TolFun',1e-1, ...
                    'ScaleProblem','Jacobian' );
failReasons =  cell( size(x0s,1), 1 );
x_iters     =  cell( size(x0s,1), 1  );
passiters   =  cell( size(x0s,1), 1  );
pass        =  cell( size(x0s,1), 1  );




% x0s = generateNormalSet( );
parfor j=1:size(x0s,1),
    if mod(j,20) == 0,
        fprintf('Initial value %d of %d\n', j, size(x0s,1));
    end
    for i=1:NUM_ITERS,
        x0 = x0s(j,:);
        if NUM_ITERS > 1 && size(im_ids,1) > 1,
            iids = im_ids(i,:);
            disp('Changing imids: ');
            iids
        else 
            iids = im_ids;
        end
        imc_use = im_coords(:,iids) ;
        try
            [ x_iter, ~, exitflag, ~ ] = fsolve( @gp_iter_func, x0, options, imc_use);
    %         fval
    %         nFactor = norm(x_iter(2:4));
    %         x_iter = [x_iter(1), x_iter(2:4)] vc;
            x_iters{j}(i,:)     = x_iter;
            plane = iter2plane(x_iter);
            [validn,validalpha] = checkPlaneValidity( plane );

            wc = find_real_world_points( im_coords, plane );
            baddist = checkDistributionFeasibility( wc, 10, 1 );

    %         f = notFit( im_coords, H, plane, 0.05 );

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
            if ~validalpha,
                fR(3) = 1;
            end
            % If distribution is invalid
            if baddist,
                fR(4) = 1;
            end
            if x_iter(4) > 0,
                fR(5) = 1;
            end

        catch err,
            if strcmp(err.identifier, 'IJH:ITERATE:IMAGINARY'),
                fR = [ 1 0 0 0 5 ];
                x_iters{j}(i,:) = [NaN,NaN,NaN,NaN];
            else
                rethrow(err);
            end
        end
        %%

        failReasons{j}(i,:) = fR;

    %     if sum(fR) == 0,
    %         pass(i) = 1;
    %     end
    pass{j}(i) = exitflag;
    if num > 0,
        fprintf('**********************************\nRun %04d, Attempt %04d\n*************************************\nPass: %d\n\n', num, i,pass{j}(i));
    end

    end
    
    passiters{j} = x_iters{j}(sum(failReasons{j}(:,1:5),2) == 0,:);
end
% 
% %% Save data    
% fld = sprintf('multiplanar_sim/%s',getTodaysFolder( ) );
% if ~exist(fld,'dir'),
%     mkdir( fld );
% end
% a        = dir(sprintf('./%s/run*.mat',fld));
% next_id  = size(a,1) + 1;
% 
% save( sprintf('%s/run_%03d.mat', fld, next_id) );
