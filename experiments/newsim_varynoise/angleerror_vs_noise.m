CDIR=cd;
addpath( CDIR ); 

setup_exp

NOISE_PARAMS     = 0:0.1:1;
HEIGHT_PARAMS    = 0:0.2:0;
NUM_NOISE        = length(NOISE_PARAMS);
NUM_HEIGHT       = length(HEIGHT_PARAMS);

NUM_TRAJECTORIES = 5;
ALPHAS           = -10.^(-3:0.25:-1);
THETAS           = 1:15:90;
PSIS             = -60:15:60;
DS               = 1:5:30;

if exist('param_file','var')
    load(param_file,'PLANE_PARAMS');
    NUM_PLANES = size(PLANE_PARAMS,2);
else
    NUM_PLANES = 20;
    PLANE_PARAMS = [ randi(90,1,NUM_PLANES)       ;
                     randi(120,1,NUM_PLANES) - 60 ; 
                     rand(1,NUM_PLANES) * 18 + 10 ;
                    -randi(10,1,NUM_PLANES).*0.001];
    save plane_params.mat PLANE_PARAMS;
end


all_x_iters      =  cell(NUM_NOISE,NUM_HEIGHT,NUM_PLANES);
all_fval         =  cell(NUM_NOISE,NUM_HEIGHT,NUM_PLANES);
all_exitflag     =  cell(NUM_NOISE,NUM_HEIGHT,NUM_PLANES);
all_output       =  cell(NUM_NOISE,NUM_HEIGHT,NUM_PLANES);
all_timeToSolve  =  cell(NUM_NOISE,NUM_HEIGHT,NUM_PLANES);
all_baseTraj     =  cell(NUM_NOISE,NUM_HEIGHT,NUM_PLANES);
all_camTraj      =  cell(NUM_NOISE,NUM_HEIGHT,NUM_PLANES);
all_imTraj       =  cell(NUM_NOISE,NUM_HEIGHT,NUM_PLANES);
all_bestiter     =  cell(NUM_NOISE,NUM_HEIGHT,NUM_PLANES);
all_bestangleerr = zeros(NUM_NOISE,NUM_HEIGHT,NUM_PLANES);
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

x0TrajGrid = generateTrajectoryInitGrid( NUM_TRAJECTORIES, x0grid );

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
    
    for nId2 = 1:NUM_HEIGHT
        fprintf('%d\tHeight Value %.1f (%d of %d)\n', pId, HEIGHT_PARAMS(nId2), nId2, NUM_HEIGHT);
        for nId = 1:NUM_NOISE
            fprintf('%d\t%d\tNoise Value %.2f (%d of %d)\n\t\t', pId, nId2, NOISE_PARAMS(nId), nId, NUM_NOISE);

            %% Set up dirs and filenames
        %     ROOT_DIR = sprintf('t=%d,p=%d,a=%.4f,d=%2.3f',GT_T,GT_P,GT_ALPHA,GT_D);
        %     addpath( cd ); 
        %     mkdir( ROOT_DIR )
        %     cd( ROOT_DIR );

            %% Generate Trajectories & Plane
            baseTraj = addTrajectoriesToPlane( basePlane, [], ...
                NUM_TRAJECTORIES, 2000, 1, 0, NOISE_PARAMS(nId), 10, ...
                0, 0);

            camTraj = cellfun(@(x) rotation(1:3,1:3)*x,baseTraj,'uniformoutput',false);

            imTraj = cellfun(@(x) traj2imc(wc2im(x,GT_ALPHA),1,1), camTraj,'uniformoutput',false);

            all_baseTraj{nId, nId2, pId}  = baseTraj;
            all_camTraj{nId, nId2, pId}   = camTraj;
            all_imTraj{nId, nId2, pId}    = imTraj;

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

            all_fval{nId, nId2, pId}        = cellfun(@(x) sum(x.^2),fval);

            [minfval,MINIDX] = min(all_fval{nId, nId2, pId});

            fprintf('\t\t  Minimum fval: %4.6f\n', minfval);

            all_bestiter{nId, nId2, pId}     = x_iter{MINIDX}; 
            all_bestangleerr(nId, nId2, pId) = angleErrors(MINIDX);
            fprintf('\t\t  Minimum angle err: %1.4f radians (%3.2f)\n',all_bestangleerr(nId,pId),rad2deg(all_bestangleerr(nId,pId)));

            all_x_iters{nId, nId2, pId}     = x_iter;
            all_exitflag{nId, nId2, pId}    = exitflag;
        %     cd ../
        end
    end
end

bestangles = reshape(all_bestangleerr(:,1,:),size(all_bestangleerr,1),size(all_bestangleerr,3))'
figure;
errorbar( NOISE_PARAMS, mean(bestangles), std(bestangles),'rx' );
axis([0 2 -0.2 pi/2] )
grid on
xlabel('Standard Deviation Inner Speed Noise (mean speed = 1)');
ylabel('Mean Angle Error Between Est and GT Planes (radians)');


% f = figure;
% offset =0;
% 
% NUM_ROWS = 2;
% NUM_COLUMNS = 2;
% NUM_CELLS = NUM_ROWS*NUM_COLUMNS;
% for i=1:NUM_NOISE    
%     
%     if (~mod(i-1,NUM_CELLS) && i > 1 && i <= NUM_NOISE) || i == NUM_NOISE
%         saveas(f, sprintf('angle_error_vs_height_%d.fig',ceil((offset+1)./NUM_CELLS)));
%         if i <= NUM_NOISE
%             offset = offset + NUM_CELLS;
%             f = figure;
%         end
%     end
%     
%     subplot(NUM_ROWS,NUM_COLUMNS,i-offset);
%     ba = reshape(all_bestangleerr(i,:,:),size(all_bestangleerr,2),size(all_bestangleerr,3));
%     
%     errorbar( HEIGHT_PARAMS, mean(ba,2), std(ba,0,2),'rx' );
%     xlabel('Per-Trajectory Height Std Dev');
%     ylabel(sprintf('Mean angle error over %d planes (radians)',NUM_PLANES));
%     title(sprintf('Inter-Traj Spd SD: %.1f',NOISE_PARAMS(i)));
%     grid on;
%     axis([0 0.5 -0.2 pi/2])
% end
% saveas(f, sprintf('angle_error_vs_height_%d.fig',ceil((offset+1)./12)));

% saveas(f, 'angle_error_vs_noise.fig')

save allexp_data;

clear expdir;

cd ../

rmpath(CDIR);
