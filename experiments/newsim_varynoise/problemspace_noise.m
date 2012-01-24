
%% Experiment Parameters
sdDrns = 0:1:30;

meanSpeed  = 1;
sdSpeed    = 0;
sdSpdInter = 0;
sdHeight   = 0;
sdDrn      = 15;

ALPHAS = -10.^(-3:0.1:-1);
THETAS = 2:2:90;
PSIS   = -60:2:60;
DS = 1:1:20;

NUM_TRAJECTORIES = 1;
GT_T = 32;
GT_P = -16;
GT_D = 10;

GT_N = normalFromAngle( GT_T,GT_P );
GT_ALPHA = ALPHAS(10);


ERROR_FUNC = @traj_iter_func;
GT_ITER = [n2abc(GT_N,GT_D)',GT_ALPHA];
MARKER_COLOUR = 'ob';

gridfn = 'fine_grid.mat';
if exist(gridfn,'file')
   load( gridfn, 'grid', 'gridVars');
else
    [grid,gridVars] = generateNormalSet( ALPHAS,DS,THETAS,PSIS );
    save( gridfn, 'grid', 'gridVars')
end

expnum = 1;
errorDiff = Inf*ones(length(sdSpeeds),1);

ROOT_DIR = sprintf('stddrn_noise/%s/',datestr(now,'HH-MM-SS'));

mkdir( ROOT_DIR )
cd( ROOT_DIR );

for sdDrn = sdDrns
    %% Set up dirs and filenames
    fStr = sprintf('mnS=%1.3f_sdS=%1.3f_sdInS=%1.3f_sdH=%1.3f_sdDrn=%1.3f', ...
                    meanSpeed, sdSpeed, sdSpdInter, sdHeight, sdDrn ...
                  );
    mkdir( fStr );
    cd( fStr );
    fixed_nms = strcat('fixed_',['d,f';'t,d';'t,f';'t,p';'p,f';'p,d']);

    %% Generate Trajectories & Plane
    basePlane = createPlane( GT_D, 0, 0, 1 );
    [baseTraj,~,~,trajSpeeds,trajHeights] = addTrajectoriesToPlane( basePlane, [], NUM_TRAJECTORIES, 2000, meanSpeed, sdSpeed, sdSpdInter, sdDrn, sdHeight);

    rotX = makehgtform('xrotate',-deg2rad(GT_T));
    rotZ = makehgtform('zrotate',-deg2rad(GT_P));
    rotation = rotZ*rotX;

    camPlane = rotation(1:3,1:3)*basePlane;
    camTraj = cellfun(@(x) rotation(1:3,1:3)*x,baseTraj,'uniformoutput',false);

    imPlane = wc2im(camPlane,GT_ALPHA);
    imTraj = cellfun(@(x) traj2imc(wc2im(x,GT_ALPHA),1,1), camTraj,'uniformoutput',false);


    pF = figure;
    subplot(1,2,1);
    drawPlane( camPlane,'',0,'k' );
    cellfun( @(x) drawcoords3(traj2imc(x,1,1),'',0,'k'),camTraj);
    axis image;
    subplot(1,2,2);
    drawPlane( imPlane,'',0,'k' );
    cellfun( @(x) drawcoords(x,'',0,'k'),imTraj);
    saveas(pF, 'trajectory.fig');

    allfigs = figure;

    %% Run scripts
    for FIXED_VARS = 1:6
        f = figure;

        expdir = fixed_nms(FIXED_VARS,:);
        examine_problem_space;

        title(strrep(sprintf('Problem space for %s', fixed_nms(FIXED_VARS,:), fStr),'_',' '));

        saveas(f,sprintf('noise_problemspace_%s.fig', fixed_nms(FIXED_VARS,:)));
        close all;
    end
    
    errorDiff(expnum) = min(err) - GT_ERR;
    expnum = expnum + 1; 
    cd ../
end
figure;bar(sdDrns,abs(errorDiff));
xlabel('Std Dev of Direction (degrees)');
ylabel('Difference between minimum error and GT error');
saveas(f,'noise_error_diffs.fig');

save expdata_all.mat

