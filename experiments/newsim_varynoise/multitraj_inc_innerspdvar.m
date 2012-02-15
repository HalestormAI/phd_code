%% Setup plane parameters
setup_exp;

INTERSPD_NOISE_PARAMS = 0:0.1:1;
NUM_EXP = length(INTERSPD_NOISE_PARAMS);

NUM_TRAJECTORIES = 10;
ALPHAS = -10.^(-3:0.5:-1);
THETAS = 1:20:90;
PSIS   = -60:20:60;
DS = 1:5:20;

NUM_PLANES = 1;
PLANE_PARAMS = [ randi(90,1,NUM_PLANES)        ;
                 randi(120,1,NUM_PLANES) - 60  ; 
                 rand(1,NUM_PLANES) * 18 + 2   ;
                -rand(1,NUM_PLANES).*0.01      ];

GT_T	 = PLANE_PARAMS(1,1);
GT_P     = PLANE_PARAMS(2,1);
GT_D     = PLANE_PARAMS(3,1);
GT_ALPHA = PLANE_PARAMS(4,1);

GT_N = normalFromAngle( GT_T,GT_P );
GT_ITER = [n2abc(GT_N,GT_D)',GT_ALPHA];

%% Build Planes
rotX = makehgtform('xrotate',-deg2rad(GT_T));
rotZ = makehgtform('zrotate',-deg2rad(GT_P));
rotation = rotZ*rotX;

basePlane = createPlane( GT_D, 0, 0, 1 );
camPlane = rotation(1:3,1:3)*basePlane;
imPlane = wc2im(camPlane,GT_ALPHA);

%% Setup experiment parameters
all_x_iters     = cell(NUM_EXP,1);
all_fval        = cell(NUM_EXP,1);
all_exitflag    = cell(NUM_EXP,1);
all_output      = cell(NUM_EXP,1);
all_timeToSolve = cell(NUM_EXP,1);
all_baseTraj    = cell(NUM_EXP,1);
all_camTraj     = cell(NUM_EXP,1);
all_imTraj      = cell(NUM_EXP,1);
all_basePlane   = cell(NUM_EXP,1);

bestiter        = cell(NUM_EXP,1);
estTraj         = cell(NUM_EXP,1);
estLengths      = cell(NUM_EXP,1);
gtLengths       = cell(NUM_EXP,1);

if matlabpool('size') == 0
    matlabpool open 3;
end
fsolve_options;

gridfn = 'fine_grid.mat';
if exist(gridfn,'file')
   load( gridfn, 'x0grid', 'gridVars');
else
    [x0grid,gridVars] = generateNormalSet( ALPHAS,DS,THETAS,PSIS );
    save( gridfn, 'x0grid', 'gridVars')
end
x0TrajGrid = generateTrajectoryInitGrid( NUM_TRAJECTORIES, x0grid );

f = figure;
offset = 0;
for n = 1:length(INTERSPD_NOISE_PARAMS);
    noise = INTERSPD_NOISE_PARAMS(n);
    
    baseTraj = addTrajectoriesToPlane( basePlane, [], NUM_TRAJECTORIES, 2000, 1, 0.2, noise, 10);
    camTraj = cellfun(@(x) rotation(1:3,1:3)*x,baseTraj,'uniformoutput',false);
    imTraj = cellfun(@(x) traj2imc(wc2im(x,GT_ALPHA),1,1), camTraj,'uniformoutput',false);
    
    all_baseTraj{n}  = baseTraj;
    all_camTraj{n}   = camTraj;
    all_imTraj{n}    = imTraj;
    
    x_iter      =  cell(size(x0grid,1),1);
    fval        =  cell(size(x0grid,1),1);
    exitflag    = zeros(size(x0grid,1),1);
    output      =  cell(size(x0grid,1),1);
    
    parfor b=1:length(x0TrajGrid)
%                 fprintf('\tInitial Estimate %d of %d\n',b, length(tobeoptimised_x0));
        [ x_iter{b}, fval{b}, exitflag(b), output{b} ] = fsolve(@(x) traj_iter_func(x, imTraj),x0TrajGrid(b,:),options);

        if ~checkPlaneValidity( iter2plane(x_iter{b}(1:4)) ) && exitflag(b) > 0
            exitflag(b) = -25;
        end
        
        if ~mod(b-1, 50)
            fprintf('Optimising x0 %d of %d for noise id %dof %d\n', b, length(x0grid), n, length(INTERSPD_NOISE_PARAMS));
        end
    end
    all_x_iters{n}     = x_iter;
    all_fval{n}        = fval;
    all_exitflag{n}    = exitflag;
    
    [~,MINIDX]    = min(cellfun(@(x) sum(x.^2),fval));
    bestiter{n}   = x_iter{MINIDX};
    
    estTraj{n}    = cellfun(@(x) find_real_world_points( x, iter2plane(bestiter{n}(1:4))),imTraj,'uniformoutput',false);
    estLengths{n} = cellfun( @(x) mean(vector_dist(x)), estTraj{n});
    estLengths{n} = (estLengths{n} ./ max(estLengths{n}))';
    
    gtLengths{n}  = cellfun(@(x) mean(vector_dist(traj2imc(x,1,1))), all_camTraj{n});
    gtLengths{n}  = gtLengths{n}' ./ max(gtLengths{n});
    compLengths   = [gtLengths{n};estLengths{n}];
    
    if ~mod(n-1,12) && n > 1 && n <= NUM_EXP
        saveas(f, sprintf('length_comparison_all_%d',ceil((offset+1)./12)));
        offset = offset + 12;
        f = figure;
    end
    subplot(3,4,n-offset);
    bar(compLengths');
    title(sprintf('Rectified Lengths, inner variation %.3f\nGT (blue) and Estimated (Red)',noise));
    xlabel('Trajectory ID');
    ylabel('Normalised Speed [l_i / max(l)]');
end