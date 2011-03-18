function [planes, mup, dist, ids, figHandles, failReasons,x0s] = getEqualLengthVecs( H, imc, DELTA, NUM_ITERS, im )

    if nargin < 3,
        DELTA = 0.05;
    end
    if nargin < 4,
        NUM_ITERS = 20;
    end
    
    MAX_ATTEMPTS = 3000;

    % Rectify using homography.
    Ch = H*makeHomogenous( imc );

    % Get plane from rectified points
    N_a = planeFromPoints( Ch );

    % normalise so mu(l) = 1
    mu_l = findLengthDist( Ch, 0 );
    Ch_norm = Ch ./ mu_l;

    % Now find those which have length 1 +/- delta


    options = optimset( 'Display', 'off', ...
                        'Algorithm', {'levenberg-marquardt',0.00001}, ...
                       'MaxFunEvals', 100000, ...
                       'MaxIter', 1000000, ...
                       'TolFun',1e-3, ...
                       'ScaleProblem','Jacobian' );


    planes = cell(NUM_ITERS,4);

    h = waitbar( 1/NUM_ITERS, sprintf('Running %d iterations',NUM_ITERS), 'Name', sprintf('Running %d iterations',NUM_ITERS) );

    failReasons = cell( NUM_ITERS, 1);
    failPlanes = cell( NUM_ITERS, MAX_ATTEMPTS);
    x0s = cell(NUM_ITERS, 1);
    image_ids = cell(NUM_ITERS, 1);

    for i=1:NUM_ITERS,
        failReasons{i} = struct('badN',0,'badD',0, 'FAIL', 0, 'badFit', 0, 'planes', {} );
        done = 0;
        attempts = 0;
        x0 = generateNormal( imc );
        
        if i == 1,
            [ids_full,usable,imids] = pickIds( Ch_norm, imc, DELTA, im );
        else
            [ids_full,usable,imids] = pickIds( Ch_norm, imc, DELTA );
        end
        waitbar(i / NUM_ITERS, h, sprintf('Iteration %d of %d (%d%%)', ...
                    i, NUM_ITERS, round(100*(i/NUM_ITERS))));
        
        % Make attempts waitbar
        A = waitbar( MAX_ATTEMPTS, 'Attempts', 'Name', ...
                    sprintf('Allowing %d iterations',MAX_ATTEMPTS));
        AW=findobj(A,'Type','Patch');
        set(AW,'EdgeColor',[0 0 1],'FaceColor',[0 0 1])
        pos_w1=get(h,'position');
        pos_w2=[pos_w1(1) pos_w1(2)+pos_w1(4) pos_w1(3) pos_w1(4)];
        set(A,'position',pos_w2,'doublebuffer','on')
        
        while ~done,
            waitbar(1-(attempts / MAX_ATTEMPTS),A, sprintf('Attempts Tried: %d', attempts));
            [ x_iter, ~, exitflag, ~ ] = fsolve( @gp_iter_func, x0, options, usable(:,ids_full) );
            [validn,validd] = checkPlaneValidity( x_iter );
            nf = notFit( imc, H, x_iter, 0.05 );

            if ~validn,
                 failReasons{i}.badN = failReasons{i}.badN + 1;
            end
            if ~validd,
                 failReasons{i}.badD = failReasons{i}.badD + 1;
            end
            if nf,
                 failReasons{i}.badFit = failReasons{i}.badFit + 1;
            end

            if exitflag < 1 || ~validn || nf,
                attempts = attempts + 1;
                x0s{i,attempts} = x0;
                image_ids{i,attempts} = imids;
                x0 = generateNormal( imc );

                if attempts >= MAX_ATTEMPTS,
%                     exception = MException('IJH:CONVERGE:FAIL', sprintf('Did not converge in 100 iterations. Exitflag: %d.', i, exitflag ));
                    %throw( exception);
                    failReasons{i}.FAIL = failReasons{i}.FAIL + 1;
                    delete(A);
                    break;
                end
            else
                planes(i,:) = x_iter;
                delete(A);
                done = 1;
            end
        end
    end
    delete(h);

    [mup,~,ff] = removeOutliersFromMean( planes, N_a );

    plane = iter2plane( mup );
%     wc = find_real_world_points( imc, plane );
    %findLengthDist( wc );

    [dist,ids,figHandles] = finalTry( Ch_norm, plane.n, imc, 50 );

    figHandles().convergences = ff;


    






end





