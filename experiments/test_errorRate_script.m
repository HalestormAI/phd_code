
if exist('imc','var') && ~exist('im_coords','var'),
    im_coords = imc;
    clear imc;
end
if exist('im2','var') && ~exist('im1','var'),
    im1 = im2;
    clear im2;
end

Ch = H*makeHomogenous( im_coords );
mu_l = findLengthDist( Ch, 0 );
Ch_norm = Ch ./ mu_l;

[~,~,im_ids] = pickIds( Ch_norm, im_coords, 0.01, im1 );

im_coords(:,im_ids)

NUM_ITERS = 10000;
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



parfor i=1:NUM_ITERS,
    fprintf('**********************************\nIteration %04d\n*************************************\n\n', i);
    x0 = generateNormal();
    x0s{i} = x0;
    [ x_iter, ~, exitflag, ~ ] = fsolve( @gp_iter_func, x0, options, im_coords(:,im_ids) );
    
    x_iters{i} = x_iter;
   
    [validn,validd] = checkPlaneValidity( x_iter );
    
    wc = find_real_world_points( im_coords, iter2plane(x_iter) );
    [mu_lwc,sd_wcl,lengths] = findLengthDist( wc, 0 );
    numbad = length(find(lengths > mu_lwc + 10*sd_wcl ));
    baddist = numbad > 1;
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

end

good_dist=find(~failReasons(:,5));

%% Save data    
fld = sprintf('errorRate/%s',getTodaysFolder( ) );
if ~exist(fld,'dir'),
    mkdir( fld );
end
a        = dir(sprintf('./%s/run*.mat',fld));
next_id  = size(a,1) + 1;

save( sprintf('%s/run_%03d.mat', fld, next_id) );
