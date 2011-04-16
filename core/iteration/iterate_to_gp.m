function [ wc, x_iter, ids_full,attempts ] = iterate_to_gp( im_coords, x0, NUM_RANDOMS, point_sampling )
% Uses the L-V algorithm to estimate the ground-plane parameters.
%
%   INPUT:
%       im_coords   A set of 2D motion vector endpoints (consecutive pairs)
%       x0          An inital condition
%       NUM_RANDOMS How many vectors should be used in the estimation?
%
%   OUTPUT:
%       wc          A set of 3D estimated world coordinates
%       x_iter      Result of the final iteration - estimated plane params
%       ids_full    Indices of the coordinates that were used


    if nargin < 2 || size(x0,2) == 1,
        x0 = generateNormal( 1:720 );
    end
    if nargin < 3,
        NUM_RANDOMS = 5;
    end
    if nargin < 4,
        point_sampling = 'SMART';
    end
    
    BAD_THRESH = 10;
    PROPORTION = 3;
    PROX_C = 1/3.0;
    
    done = 0;
    attempts = 0;
    while ~done,

        if strcmp(point_sampling, 'MAXDIST'),
                ids_full = maxPaths( im_coords, NUM_RANDOMS,0.01,0);
        elseif strcmp(point_sampling, 'MONTECARLO'),

            ids_full = monteCarloPaths( im_coords, NUM_RANDOMS,3,15 );
        elseif strcmp(point_sampling, 'SMART'),
            while 1,
                try
                    ids_full = smartSelection(im_coords, NUM_RANDOMS, PROX_C );
                    break;
                catch ex,
                    if strcmp(ex.identifier, 'IJH:VECSEL:OUTOFVECS'),
                        PROX_C = PROX_C * 0.75;
                        disp('  OUT OF VECTORS ' );
                        continue;
                    else
                        rethrow(ex);
                    end
                end
            end
        else
             r = randperm(size(im_coords,2)/2);
             ids = r(1:NUM_RANDOMS) .* 2 -1;
             ids_full = sort( [ ids, (ids + 1) ] );
        end

        options = optimset( 'Display', 'off', 'Algorithm', {'levenberg-marquardt',0.001}, 'MaxFunEvals', 100000, 'MaxIter', 1000000, 'TolFun',1e-11,'ScaleProblem','Jacobian' );

        [ x_iter, fval, exitflag, output ] = fsolve( @gp_iter_func, x0, options, im_coords(:,ids_full) );


        iters = output.iterations;
        pass = 1;
        if exitflag > 1,
            exception = MException('AcctError:Incomplete', sprintf('Did not converge in %d iterations. Exitflag: %d.', iters, exitflag ));
           % fprintf('Used ids:'); ids_full
          %  disp( exception.message  );
                 
            %throw(exception)
            attempts = attempts + 1;
            if (attempts) > 10,
               throw( exception );
            end
            if (attempts) > 1,
                if strcmp(point_sampling , 'MONTECARLO'),
                    disp('Trying random sampling in the hope of finding some answer.');
                    point_sampling = 'RANDOM';
                elseif strcmp(point_sampling , 'SMART') && attempts > 10,
                    disp('DECREASING PROXIMITY COEFFICIENT.');
                    PROX_C = PROX_C * 0.75;
                end
            end
              x0 = generateNormal( im_coords );
        else
            

            plane = iter2plane(x_iter);
            wc = find_real_world_points( im_coords, plane );
            done = 1;
            nFactor = norm(x_iter(2:4));
            x_iter = [x_iter(1), x_iter(2:4)./nFactor, x_iter(5)];
        end
    end
    
end
