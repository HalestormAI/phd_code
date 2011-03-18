function [mup] = stage2( imc, pln, DELTA, NUM_ITERS, run )

if nargin < 3,
    DELTA = 0.05;
end
if nargin < 4,
    NUM_ITERS = 20;
end

% Rectify using input n.
Ch = find_real_world_points( imc, iter2plane( pln ) );

N_a = pln(2:4)';

% normalise so mu(l) = 1
mu_l = findLengthDist( Ch, 0 );
Ch_norm = Ch ./ mu_l;

PROX_C = 0.5;

gotpoints = 0;
while ~gotpoints
    % Now find those which have length 1 +/- delta
    [~, ~, lengths] = findLengthDist( Ch_norm, 0 );
    idx_1 = find( and( (lengths > 1 - DELTA) , (lengths < 1 + DELTA) ) );
    full_idx = sort([(2.*idx_1-1),(2.*idx_1-1)+1]);
    usable = imc( :, full_idx );
    
    while 1,
        try
            ids_full = smartSelection( usable, 3, PROX_C );
            break;
        catch ex,
            if strcmp(ex.identifier, 'VECSEL:OUTOFVECS'),
                disp('  OUT OF VECTORS ' );
                PROX_C = PROX_C * 0.75;
                continue;
            end
        end
    end

end



options = optimset( 'Display', 'off', ...
                    'Algorithm', {'levenberg-marquardt',0.00001}, ...
                   'MaxFunEvals', 100000, ...
                   'MaxIter', 1000000, ...
                   'TolFun',1e-3, ...
                   'ScaleProblem','Jacobian' );


planes = zeros(NUM_ITERS,4);

h = waitbar( 1/NUM_ITERS, sprintf('Stage2 - %d: Running %d iterations',run, NUM_ITERS), ...
    'Name', sprintf('Stage2 - %d: Running %d iterations',run, NUM_ITERS) );

for i=1:NUM_ITERS,
    
    done = 0;
    attempts = 0;
    x0 = pln;
    
    waitbar(i / NUM_ITERS, h, sprintf('Iteration %d of %d (%d%%)', i, NUM_ITERS, round(100*(i/NUM_ITERS))));
    while ~done,
        [ x_iter, fval, exitflag, output ] = fsolve( @gp_iter_func, x0, options, usable(:,ids_full) );

        validn = checkPlaneValidity( x_iter );

        if exitflag < 1 || ~validn,
            attempts = attempts + 1;
            if (attempts) > 500,
                exception = MException('AcctError:Incomplete', sprintf('Did not converge in %d iterations. Exitflag: %d.', i, exitflag ));
                disp('AFTER 500 ATTEMPTS!!!!!!!!!!!!');
               throw( exception );
            end
            x0 = generateNormal( imc );
        else
            planes(i,:) = x_iter;
            done = 1;
        end
    end
end
delete(h);

mup = removeOutliersFromMean( planes, N_a .* -1, 0);

% plane = iter2plane( mup );
% wc = find_real_world_points( imc, plane );
% findLengthDist( wc );
% 
% ids = finalTry( Ch_norm, plane.n, imc, 50 );

















