% How do we do with no speed variation?
NUM_PLANES = 250;

% Generate a set of random camera positions in the form (thetas ; psis ; ds )
if ~exist('PLANE_PARAMS','var')
    PLANE_PARAMS = [ randi(90,1,NUM_PLANES)              ;
                     randi(90,1,NUM_PLANES) - 45         ;
                    (rand(1,NUM_PLANES) * 18 + 2) * 1000 ];
             
    FOCAL = 250;
end

fsolve_options;

% Get set of trajectories in world
fid = fopen('progress.txt', 'w');
fprintf(fid, 'Creating Trajectories\n');
fclose( fid );
FPS = 12;

if ~exist('basePlane','var')
    [basePlane,camPlane,rotation] = createPlane( 10000, 0, 0, 25 );
end
if  ~exist('baseTraj','var')
    [baseTraj] = addTrajectoriesToPlane( basePlane, [], 10, 2000, 1500/FPS, 0, 0 );
end

drawPlane(basePlane);
cellfun( @(x) drawcoords(traj2imc(x,12,1),'',0,'k'), baseTraj);
planeBounds = minmax(basePlane);
axis([planeBounds(1,:),planeBounds(2,:),-250000/2,250000/2]);

NUM_EQNS = cell(size(PLANE_PARAMS,2),1);

SPEEDDIST_EST = cell(size(PLANE_PARAMS,2),1);
SPEEDDIST_GT = cell(size(PLANE_PARAMS,2),1);
RESULT = cell(size(PLANE_PARAMS,2),1);

if ~exist('grid','var')
    grid = generateNormalSet( 10.^(-3:0.25:-1),1000:1000:20000 );
end
save pretestdata basePlane baseTraj PLANE_PARAMS grid
disp('Base params sorted, starting loop');

fid = fopen('progress.txt', 'a');
fprintf(fid, 'Base params sorted, starting loop\n');
fclose( fid );

all_x0s    = cell( size(PLANE_PARAMS,2) );
all_xiters = cell( size(PLANE_PARAMS,2) );
all_exits  = cell( size(PLANE_PARAMS,2) );

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
    
    N = normalFromAngle( 180-theta, psi );
    D = d;
    
    % Take all trajectories
    tobeoptimised_traj = cellfun( @(x) traj2imc(x, FPS, 1), imTraj, 'uniformoutput',false );
            
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
    RESULT{p} = x_iters_good{MINIDX};

    if exist('H', 'var')
        gt_traj = cellfun(@(x) H*makeHomogenous(x), tobeoptimised_traj,'uniformoutput',false);
    elseif exist('N','var') && exist('D','var')
        gt_traj = cellfun(@(x) find_real_world_points(x,iter2plane([N'./D,FOCAL])), tobeoptimised_traj,'uniformoutput',false);

    else
        error('Not enough info for a ground-truth.')
    end
    est_traj = cellfun(@(x) find_real_world_points(x,iter2plane(x_iters_good{MINIDX}(1:4))), tobeoptimised_traj,'uniformoutput',false);

    all_x0s{p} = tobeoptimised_x0;
    all_xiters{p} = x_iter;
    all_exits{p} = exitflag;

    fprintf('Plane %d/%d complete.\n',p, size(PLANE_PARAMS,2));
    fid = fopen('progress.txt', 'a');
    fprintf(fid, 'Plane %d/%d complete.\n',p, size(PLANE_PARAMS,2));
    fclose( fid );

end
fid = fopen('progress.txt', 'a');
fprintf(fid, 'COMPLETED');
fclose( fid );