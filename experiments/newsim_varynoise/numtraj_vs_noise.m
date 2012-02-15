CDIR=cd;
addpath( CDIR ); 

setup_exp

MAX_TRAJ = 20;


ALPHAS           = -10.^(-3:0.5:-1);
THETAS           = 1:20:90;
PSIS             = -60:20:60;
DS               = 1:5:30;

if exist('param_file','var')
    load(param_file,'PLANE_PARAMS');
    NUM_PLANES = size(PLANE_PARAMS,2);
else
    NUM_PLANES = 100;
    PLANE_PARAMS = [ randi(90,1,NUM_PLANES)       ;
                     randi(120,1,NUM_PLANES) - 60 ; 
                     rand(1,NUM_PLANES) * 18 + 10 ;
                    -randi(10,1,NUM_PLANES).*0.001];
    save plane_params.mat PLANE_PARAMS;
end


all_x_iters      =  cell(MAX_TRAJ,NUM_PLANES);
all_fval         =  cell(MAX_TRAJ,NUM_PLANES);
all_exitflag     =  cell(MAX_TRAJ,NUM_PLANES);
all_output       =  cell(MAX_TRAJ,NUM_PLANES);
all_timeToSolve  =  cell(MAX_TRAJ,NUM_PLANES);
all_baseTraj     =  cell(MAX_TRAJ,NUM_PLANES);
all_camTraj      =  cell(MAX_TRAJ,NUM_PLANES);
all_imTraj       =  cell(MAX_TRAJ,NUM_PLANES);
all_bestiter     =  cell(MAX_TRAJ,NUM_PLANES);
all_bestangleerr = zeros(MAX_TRAJ,NUM_PLANES);
all_basePlane    =  cell(NUM_PLANES,1);
all_camPlane     =  cell(NUM_PLANES,1);
all_imPlane      =  cell(NUM_PLANES,1);


if matlabpool('size') == 0
    matlabpool open 3;
end

gridfn = 'fine_grid.mat';
if exist(gridfn,'file')
   load( gridfn, 'x0grid', 'gridVars');
else
    [x0grid,gridVars] = generateNormalSet( ALPHAS,DS,THETAS,PSIS );
    save( gridfn, 'x0grid', 'gridVars')
end

for pId = 1:NUM_PLANES

    fprintf('Estimating Plane %d of %d\n', pId, NUM_PLANES);

    %% Experiment Parameters
    GT_T	 = PLANE_PARAMS(1,pId);
    GT_P     = PLANE_PARAMS(2,pId);
    GT_D     = PLANE_PARAMS(3,pId);
    GT_ALPHA = PLANE_PARAMS(4,pId);

    GT_N = normalFromAngle( GT_T,GT_P );
    GT_ITER = [n2abc(GT_N,GT_D)',GT_ALPHA];

    rotX = makehgtform('xrotate',-deg2rad(GT_T));
    rotZ = makehgtform('zrotate',-deg2rad(GT_P));
    rotation = rotZ*rotX;
    
    basePlane = createPlane( GT_D, 0, 0, 1 );
    camPlane = rotation(1:3,1:3)*basePlane;
    imPlane = wc2im(camPlane,GT_ALPHA);
    
    all_basePlane{pId} = basePlane;
    all_camPlane{pId} = camPlane;
    all_imPlane{pId} = imPlane;
    
    for nId = 1:MAX_TRAJ
        fprintf('\tNum Trajectories %d (max: %d)\n\t',  nId, MAX_TRAJ);


        x0TrajGrid = generateTrajectoryInitGrid( nId, x0grid );
        %% Set up dirs and filenames
    %     ROOT_DIR = sprintf('t=%d,p=%d,a=%.4f,d=%2.3f',GT_T,GT_P,GT_ALPHA,GT_D);
    %     addpath( cd ); 
    %     mkdir( ROOT_DIR )
    %     cd( ROOT_DIR );

        %% Generate Trajectories & Plane
        baseTraj = addTrajectoriesToPlane( basePlane, [], nId, 2000, 1, 0, .1, 10);

        camTraj = cellfun(@(x) rotation(1:3,1:3)*x,baseTraj,'uniformoutput',false);

        imTraj = cellfun(@(x) traj2imc(wc2im(x,GT_ALPHA),1,1), camTraj,'uniformoutput',false);

        all_baseTraj{nId, pId}  = baseTraj;
        all_camTraj{nId, pId}   = camTraj;
        all_imTraj{nId, pId}    = imTraj;

    %    pF = drawPlane( imPlane );
    %    cellfun( @(x) drawcoords(x,'',0,'k'),imTraj);
    %    saveas(pF, 'trajectory.fig');
    %    close(pF);

        %% Optimise
        fsolve_options

        x_iter      =  cell(size(x0grid,1),1);
        fval        =  cell(size(x0grid,1),1);
        exitflag    = zeros(size(x0grid,1),1);

        parfor b=1:length(x0TrajGrid)
    %                 fprintf('\tInitial Estimate %d of %d\n',b, length(tobeoptimised_x0));
            [ x_iter{b}, fval{b}, exitflag(b)] = fsolve(@(x) traj_iter_func(x, imTraj),x0TrajGrid(b,:),options);

            if ~checkPlaneValidity( iter2plane(x_iter{b}(1:4)) ) && exitflag(b) > 0
                exitflag(b) = -25;
            end
            
            angleErrors(b) = angleError( GT_N, abc2n(x_iter{b}(1:3)),1,'radians' );
        end
        
        all_fval{nId, pId}        = cellfun(@(x) sum(x.^2),fval);
        
        [minfval,MINIDX] = min(all_fval{nId, pId});
        
        fprintf('\tMinimum fval: %4.6f\n', minfval);
        
        all_bestiter{nId,pId}     = x_iter{MINIDX}; 
        all_bestangleerr(nId,pId) = angleErrors(MINIDX);
        fprintf('\tMinimum angle err: %1.4f radians (%3.2f)\n',all_bestangleerr(nId,pId),rad2deg(all_bestangleerr(nId,pId)));
        
        all_x_iters{nId, pId}     = x_iter;
        all_exitflag{nId, pId}    = exitflag;
    %     cd ../
    end
end

f = figure;
% scatter( NOISE_PARAMS, mean(all_bestangleerr,2) )
errorbar( 1:MAX_TRAJ, mean(all_bestangleerr,2), std(all_bestangleerr,0,2),'rx' );
xlabel('Number of Trajectories');
ylabel(sprintf('Mean angle error over %d planes (radians)',NUM_PLANES));
title('Number of Trajectory Against Angular Error');
grid on;
axis([1 MAX_TRAJ -0.2 pi/2])
saveas(f, 'angle_error_vs_noise.fig')

save allexp_data;

clear expdir;

cd ../

rmpath(CDIR);