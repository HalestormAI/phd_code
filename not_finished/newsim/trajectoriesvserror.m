% How does plane estimation with number of trajectories? %

% Measurements in mm...


NUM_PLANES = 1000;

% Generate a set of random camera positions in the form (thetas ; psis ; ds )
if ~exist('PLANE_PARAMS','var')
    PLANE_PARAMS = [ randi(90,1,NUM_PLANES)              ;
                     randi(90,1,NUM_PLANES) - 45         ;
                    (rand(1,NUM_PLANES) * 18 + 2) * 1000 ];
             
    FOCAL = 250;
end
             

% Get set of trajectories in world
fid = fopen('progress.txt', 'w');
fprintf(fid, 'Creating Trajectories\n');
fclose( fid );
FPS = 12;

if ~exist('basePlane','var')
    [basePlane,camPlane,rotation] = createPlane( 10000, 0, 0, 25 );
end
if  ~exist('baseTraj','var')
    [baseTraj] = addTrajectoriesToPlane( basePlane, rotation, 20, 2000, 1500/FPS, 0 );
end


NUM_EQNS = cell(size(PLANE_PARAMS,2),1);
UNKNOWNS = zeros(length(baseTraj),1);

SPEEDDIST_EST = cell(size(PLANE_PARAMS,2),length(baseTraj));
SPEEDDIST_GT = cell(size(PLANE_PARAMS,2),length(baseTraj));
RESULT = cell(size(PLANE_PARAMS,2),length(baseTraj));
for i = 1:length(baseTraj)
    UNKNOWNS(i) = 4+i;
end

if ~exist('grid','var')
    grid = generateNormalSet( (10^-3).*(1:4:10),1000:2000:20000 );
end
save pretestdata basePlane baseTraj PLANE_PARAMS grid
disp('Base params sorted, starting loop');

fid = fopen('progress.txt', 'a');
fprintf(fid, 'Base params sorted, starting loop\n');
fclose( fid );

TOTAL_RUNS = size(PLANE_PARAMS,2)*length(baseTraj);

h = waitbar(0,'Starting...', 'Name', sprintf('%d iterations', TOTAL_RUNS));
one_iter_time = 1;
for p=1:size(PLANE_PARAMS,2)
    
    % View world trajectories from our camera angle
    theta = PLANE_PARAMS(1,p);
    psi   = PLANE_PARAMS(2,p);
    d     = PLANE_PARAMS(3,p);
    
    rotX = makehgtform('xrotate',deg2rad(theta));
    rotZ = makehgtform('zrotate',deg2rad(psi));
    rotation = rotX*rotZ;
    tmpPlane = basePlane;
    camPlane = rotation(1:3,1:3)*tmpPlane;
    camTraj = cellfun(@(x) rotation(1:3,1:3)*x,baseTraj,'uniformoutput',false);
     
    imPlane = wc2im(camPlane,-1/FOCAL);
    imTraj = cellfun(@(x) wc2im(x,-1/FOCAL), camTraj,'uniformoutput',false);
    
    NUM_EQNS{p} = zeros(length(baseTraj),1);
    
    
    N = normalFromAngle( 180-theta, psi );
    D = d;
    
    for i = 1:length(baseTraj);
        try
            tic;
            NUM_DONE = (p-1)*length(baseTraj) + i;
            
            waitbar(NUM_DONE / TOTAL_RUNS, h, sprintf('Running Iteration: %d (%d%%).',NUM_DONE, round(100*NUM_DONE / TOTAL_RUNS) ));
            % Pick i trajectories at random
            tperm = randperm( length(baseTraj) );

            trajectories = baseTraj(tperm(1:i));

            traj_im = cellfun( @(x) traj2imc(x, FPS), trajectories, 'uniformoutput',false );
            tobeoptimised_traj = filterTrajectories( traj_im, 5, 5 );

            NUM_EQNS{p}(i) = sum(cellfun(@length,tobeoptimised_traj));

            if NUM_EQNS{p}(i) < UNKNOWNS(i)
                error('Too few equations');
            end

            x0s = generateTrajectoryInitGrid( length(tobeoptimised_traj), grid );
            err = Inf*ones(length(x0s),1);

            disp('Building Error Vector');
            errTic = tic;
            parfor x=1:length(x0s)
                err(x) = sum(traj_iter_func(x0s(x,:), tobeoptimised_traj).^2);
            end
            toc(errTic)

            [~,SIDS] = sort(err);

            disp('Selecting x0s');
            % Take the best 1% of initial conditions
            tobeoptimised_x0 = x0s(SIDS(1:round(length(SIDS)*0.01)),:);

            fsolve_options;
            x_iter      =  cell(size(tobeoptimised_x0,1),1);
            fval        =  cell(size(tobeoptimised_x0,1),1);
            exitflag    = zeros(size(tobeoptimised_x0,1),1);
            output      =  cell(size(tobeoptimised_x0,1),1);


            disp('Optimising');
            solveTic = tic;
            parfor b=1:length(tobeoptimised_x0)
%                 fprintf('\tInitial Estimate %d of %d\n',b, length(tobeoptimised_x0));
                [ x_iter{b}, fval{b}, exitflag(b), output{b} ] = fsolve(@(x) traj_iter_func(x, tobeoptimised_traj),tobeoptimised_x0(b,:),options);
                
                if ~checkPlaneValidity( iter2plane(x_iter{b}(1:4)) )
                    exitflag(b) = -25;
                end
                    
            end
            toc(solveTic)

            if(isempty(find(exitflag > 0,1)))
                disp('No Vectors Found');
                continue;
            end
            x_iters_good = x_iter(exitflag > 0);
            errors = cellfun( @(x) sum(traj_iter_func(x,tobeoptimised_traj).^2), x_iters_good);
            [~,MINIDX] = min(errors);
            RESULT{p,i} = x_iters_good{MINIDX};

            if exist('H', 'var')
                gt_traj = cellfun(@(x) H*makeHomogenous(x), tobeoptimised_traj,'uniformoutput',false);
            elseif exist('N','var') && exist('D','var')
                gt_traj = cellfun(@(x) find_real_world_points(x,iter2plane([N'./D,FOCAL])), tobeoptimised_traj,'uniformoutput',false);

            else
                error('Not enough info for a ground-truth.')
            end
            est_traj = cellfun(@(x) find_real_world_points(x,iter2plane(x_iters_good{MINIDX}(1:4))), tobeoptimised_traj,'uniformoutput',false);


            mu_gt  = findLengthDist( cell2mat(gt_traj),0);
            mu_est = findLengthDist(cell2mat(est_traj),0);


            gt_norm = cellfun( @(x) x ./ mu_gt, gt_traj,'uniformoutput',false);
            est_norm = cellfun( @(x) x ./ mu_est, est_traj,'uniformoutput',false);
            SPEEDDIST_EST{p,i} = cellfun(@(x) mean(vector_dist(x)), est_norm);
            SPEEDDIST_GT{p,i} = cellfun(@(x) mean(vector_dist(x)), gt_norm);
            if NUM_DONE == 1
                one_iter_time = toc;
            end
            
            
            fid = fopen('progress.txt', 'a');
            fprintf(fid, 'Trajectory %d/%d for plane %d/%d complete.\n',i,length(baseTraj),p, size(PLANE_PARAMS,2));
            fclose( fid );

        catch err
            fid = fopen('progress.txt', 'a');
            fprintf(fid, 'ERROR: \N');
            fprintf(fid, err.message);
            fprintf(fid, '\n');
            fclose( fid );
            disp(err.message)    
            continue;
        end
    end
end
        fid = fopen('progress.txt', 'a');
        fprintf(fid, 'COMPLETED');
        fclose( fid );

delete(h);