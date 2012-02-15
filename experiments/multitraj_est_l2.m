
CDIR=cd;
addpath( CDIR ); 

setup_exp


NUM_TRAJECTORIES = 10;
ALPHAS = -10.^(-3:0.5:-1);
THETAS = 1:20:90;
PSIS   = -60:20:60;
DS = 1:5:20;

if exist('param_file','var')
    load(param_file,'PLANE_PARAMS');
    NUM_PLANES = size(PLANE_PARAMS,2);
else
    NUM_PLANES = 10;
    PLANE_PARAMS = [ randi(90,1,NUM_PLANES)            ;
                     randi(120,1,NUM_PLANES) - 60      ; 
                     rand(1,NUM_PLANES) * 18 + 2       ;
                    -rand(1,NUM_PLANES).*0.01];
    save plane_params.mat PLANE_PARAMS;
end


all_x_iters     = cell(NUM_PLANES,1);
all_fval        = cell(NUM_PLANES,1);
all_exitflag    = cell(NUM_PLANES,1);
all_output      = cell(NUM_PLANES,1);
all_timeToSolve = cell(NUM_PLANES,1);
all_baseTraj    = cell(NUM_PLANES,1);
all_camTraj     = cell(NUM_PLANES,1);
all_imTraj      = cell(NUM_PLANES,1);
all_basePlane   = cell(NUM_PLANES,1);
all_camPlane    = cell(NUM_PLANES,1);
all_imPlane     = cell(NUM_PLANES,1);


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

    %% Set up dirs and filenames
%     ROOT_DIR = sprintf('t=%d,p=%d,a=%.4f,d=%2.3f',GT_T,GT_P,GT_ALPHA,GT_D);
%     addpath( cd ); 
%     mkdir( ROOT_DIR )
%     cd( ROOT_DIR );

    %% Generate Trajectories & Plane
    basePlane = createPlane( GT_D, 0, 0, 1 );
    baseTraj = addTrajectoriesToPlane( basePlane, [], NUM_TRAJECTORIES, 2000, 1, 0, 0, 10);

    rotX = makehgtform('xrotate',-deg2rad(GT_T));
    rotZ = makehgtform('zrotate',-deg2rad(GT_P));
    rotation = rotZ*rotX;

    camPlane = rotation(1:3,1:3)*basePlane;
    camTraj = cellfun(@(x) rotation(1:3,1:3)*x,baseTraj,'uniformoutput',false);

    imPlane = wc2im(camPlane,GT_ALPHA);
    imTraj = cellfun(@(x) traj2imc(wc2im(x,GT_ALPHA),1,1), camTraj,'uniformoutput',false);

    all_baseTraj{pId}  = baseTraj;
    all_camTraj{pId}   = camTraj;
    all_imTraj{pId}    = imTraj;
    all_basePlane{pId} = basePlane;
    all_camPlane{pId} = camPlane;
    all_imPlane{pId} = imPlane;
    
%    pF = drawPlane( imPlane );
%    cellfun( @(x) drawcoords(x,'',0,'k'),imTraj);
%    saveas(pF, 'trajectory.fig');
%    close(pF);
    
    %% Optimise
    fsolve_options

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
    end
    if(isempty(find(exitflag > 0,1)))
        disp('No Vectors Found');
        continue;
    end
    all_x_iters{pId}     = x_iter;
    all_fval{pId}        = fval;
    all_exitflag{pId}    = exitflag;
%     cd ../
end


bestiter   = cell(length(all_x_iters),1);
estLengths = cell(length(all_x_iters),1);
gtLengths  = cell(length(all_x_iters),1);

f = figure;
offset = 0;
for i=1:length(all_x_iters)    
    GT_T	 = PLANE_PARAMS(1,i);
    GT_P     = PLANE_PARAMS(2,i);
    GT_D     = PLANE_PARAMS(3,i);
    GT_ALPHA = PLANE_PARAMS(4,i);

    GT_N = normalFromAngle( GT_T,GT_P );
    GT_ITER = [n2abc(GT_N,GT_D)',GT_ALPHA];
    if ~isempty(all_fval{i})
        
        goodfval  = all_fval{i}(all_exitflag{i} > 0);
        gooditers = all_x_iters{i}(all_exitflag{i} > 0);
        
        [~,MINIDX] = min(cellfun(@(x) sum(x.^2),goodfval));
        bestiter{i} = gooditers{MINIDX};
    
        estLengths{i} = bestiter{i}(5:end) ./ max(bestiter{i}(5:end));
        gtLengths{i} = cellfun(@(x) mean(vector_dist(x)), all_camTraj{i});
        gtLengths{i} = gtLengths{i}' ./ max(gtLengths{i});
        compLengths = [estLengths{i};gtLengths{i}];
    end
    
    if ~mod(i-1,12) && i > 1 && i <= NUM_PLANES
        saveas(f, sprintf('length_comparison_all_%d',ceil((offset+1)./12)));
        offset = offset + 12;
        f = figure;
    end
    
    if ~isempty(all_fval{i})
        subplot(3,4,i-offset);
        bar(compLengths');
%     saveas(f, sprintf('length_comparison_%d',i));
    end
    
end
saveas(f, sprintf('length_comparison_all_%d',ceil((offset+1)./12)));

save allexp_data;

clear expdir;

cd ../

rmpath(CDIR);