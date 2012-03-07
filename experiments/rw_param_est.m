CDIR=cd;
addpath( CDIR );

NUM_TRAJECTORIES = 5;
ALPHAS           = 10.^(-3:.5:3);
THETAS           = 1:15:90;
PSIS             = -60:15:60;
DS               = 1:5:30;

if exist('vid_data.mat','file')
    load vid_data imTraj H;
    disp('**Loading Trajectories From File**');
else
    vid_path= input('Video Data File: ','s')
    [~,vid_name] = fileparts(vid_path);
    vid_name = strcat(vid_name,datestr(now( ),'HH-MM-SS'));
    load( vid_path, 'imTraj', 'H', 'frame' );
end

imTraj_offset = imTraj;

imTraj = recentreImageTrajectories( imTraj, frame );

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


trajLengths = cellfun(@length,imTraj);
goodTraj = imTraj(and((trajLengths./2 > 3),(trajLengths./2 < 10)));

useTraj = goodTraj(randi(length(goodTraj),1,NUM_TRAJECTORIES));


fsolve_options
x0TrajGrid = generateTrajectoryInitGrid( NUM_TRAJECTORIES, x0grid );

x_iter      =  cell(size(x0grid,1),1);
fval        =  cell(size(x0grid,1),1);
exitflag    = zeros(size(x0grid,1),1);
 
parfor b=1:length(x0TrajGrid)
    %                 fprintf('\tInitial Estimate %d of %d\n',b, length(tobeoptimised_x0));
    [ x_iter{b}, fval{b}, exitflag(b)] = fsolve(@(x) traj_iter_func(x, useTraj),x0TrajGrid(b,:),options);
end

fvals_ss = cellfun(@(x) sum(x.^2),fval);

[minfval, minid] = min(fvals_ss);

[estN,estD] = abc2n(x_iter{minid}(1:3));
estAlpha = x_iter{minid}(4);


% Draw RW lengths in histograms
gtTraj = cellfun( @(x) H*makeHomogenous(x),useTraj,'uniformoutput',false);
lengths = cellfun(@vector_dist,gtTraj,'uniformoutput',false);
figure;
maxFD = 0;
for I=1:length(lengths)
    subplot(2,3,I);
    [hL,hX] = hist(lengths{I}./mean(lengths{I}));
    norm_hL = hL./sum(hL);
    if max(norm_hL) > maxFD,
        maxFD = max(norm_hL);
    end
    bar( hX, norm_hL );
    axis([ 0 2 0 1]);
    xlabel('Normalised Length');
    ylabel('Frequency Density');
    title(sprintf('Trajectory contains %d vectors',length(lengths{I})));
end
set(findall(gcf,'Type','axes'),'YLim',[0 maxFD])
suplabel('Distributions of normalised vector speeds for used trajectories','t')

figure;hist(cellfun(@(x) mean(vector_dist(x)),useTraj));
xlabel('Trajectory Mean Speed');ylabel('Frequency')
xlabel('Normalised Length');
ylabel('Frequency Density');
title('Trajectory  Mean Speed Distribution (5 Trajectories)');

save expdata;
