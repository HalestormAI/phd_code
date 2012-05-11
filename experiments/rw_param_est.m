CDIR=cd;
addpath( CDIR );

NUM_TRAJECTORIES = 30;
ALPHAS           = 10.^(-5:.5:5);
THETAS           = 1:15:90;
PSIS             = -60:15:60;
DS               = [0.01,0.1,1,10,100,1000];

if exist('vid_data.mat','file')
    load vid_data imTraj H;
    disp('**Loading Trajectories From File**');
else
    vid_path= input('Video Data File: ','s')
    [~,vid_name] = fileparts(vid_path);
    vid_name = strcat(vid_name,datestr(now( ),'HH-MM-SS'));
    load( vid_path, 'imTraj', 'H', 'frame' );
end

traj = imc2traj(imTraj);
imTraj = cellfun(@(x) traj2imc(x,25,1), traj,'uniformoutput',false);


trajLengths = cellfun(@length,imTraj);
imTraj(~trajLengths) = [];
imTraj_offset = imTraj;
imTraj = recentreImageTrajectories( imTraj, frame );
trajLengths = cellfun(@length,imTraj);

goodTraj = imTraj(and((trajLengths./2 > 5),(trajLengths./2 < 10)));

trajAngles = cellfun( @trajectoryAngle, goodTraj );
figure;rose(deg2rad(trajAngles),360)
useTraj = goodTraj( subsampleByDrn( trajAngles, NUM_TRAJECTORIES ) );

figure;
usedLengths = cellfun(@length,useTraj);
usedLengths = usedLengths ./ max(usedLengths);
usedAngles  = cellfun( @trajectoryAngle, useTraj );

for i=1:length(useTraj)
    l = usedLengths(i);
    a = usedAngles(i);
    
    x = sin(a)/l;
    y = cos(a)/l;
    vectarrow([0;0],[x;y]);
    hold on;
end


% useTraj = goodTraj(randi(length(goodTraj),1,NUM_TRAJECTORIES));

expdir = vid_name;

setup_exp;

if matlabpool('size') == 0
    matlabpool open 3;
end

gridfn = 'fine_grid.mat';
if exist(gridfn,'file')
    disp('**Loading Grid From File**');
    load( gridfn, 'x0grid', 'gridVars');
else
    [x0grid,gridVars] = generateNormalSet( ALPHAS,DS,THETAS,PSIS );
    save( gridfn, 'x0grid', 'gridVars')
end


fsolve_options
x0TrajGrid = generateTrajectoryInitGrid( NUM_TRAJECTORIES, x0grid );

x_iter      =  cell(size(x0grid,1),1);
fval        =  cell(size(x0grid,1),1);
exitflag    = zeros(size(x0grid,1),1);
 
parfor b=1:length(x0TrajGrid)
    %                 fprintf('\tInitial Estimate %d of %d\n',b, length(tobeoptimised_x0));
    [ x_iter{b}, fval{b}, exitflag(b)] = fsolve(@(x) traj_iter_func(x, useTraj),x0TrajGrid(b,:),options);
end

fvalErrors = cellfun(@(x) sum(x.^2),fval);

[minfval, minid] = min(fvalErrors);

[estN,estD] = abc2n(x_iter{minid}(1:3));
estAlpha = x_iter{minid}(4);


% Draw RW lengths in histograms
gtTraj = cellfun( @(x) H*makeHomogenous(x),useTraj,'uniformoutput',false);
useTraj_est=cellfun(@(x) find_real_world_points(x,iter2plane(x_iter{minid}(1:4))),useTraj,'uniformoutput',false);


drawTrajectorySpeedHists(gtTraj,useTraj_est);

figure;
subplot(1,2,1)
hist(cellfun(@(x) mean(vector_dist(x)),gtTraj));
title('Ground Truth');
xlabel('Trajectory Mean Speed');ylabel('Frequency')
subplot(1,2,2)
hist(cellfun(@(x) mean(vector_dist(x)),useTraj_est));
title('Estimated');
xlabel('Trajectory Mean Speed');ylabel('Frequency')
suptitle('Trajectory  Mean Speed Distribution (5 Trajectories)');

xiters = vertcat(x_iter{:});
fvalErrors = cellfun(@(x) sum(x.^2),fval);
[~,SORTEDFVALS] = sort(fvalErrors);
N = findNormalFromH(H);
angleErrors = cell2mat(cellfun(@(x) angleError(N.a,abc2n(x(1:3)),1),x_iter,'uniformoutput',false));

save expdata;
