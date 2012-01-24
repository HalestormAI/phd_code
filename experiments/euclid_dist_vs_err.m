% % Given clean data, how far away can we start and still find happiness?
% 
% setup_exp;
% 
% %% Experiment Parameters
% meanSpeed  = 1;
% sdSpeed    = 0;
% sdSpdInter = 0;
% sdHeight   = 0;
% sdDrn      = 15;
% 
% ALPHAS = -10.^(-3:0.1:-1);
% THETAS = 2:2:90;
% PSIS   = -60:2:60;
% DS = 1:1:20;
% 
% NUM_TRAJECTORIES = 1;
% GT_T = 32;
% GT_P = -16;
% GT_D = 10;
% 
% GT_N = normalFromAngle( GT_T,GT_P );
% GT_ALPHA = ALPHAS(10);
% 
% GT_ITER = [n2abc(GT_N,GT_D)',GT_ALPHA];
% 
% gridfn = 'fine_grid.mat';
% if exist(gridfn,'file')
%    load( gridfn, 'x0Grid', 'gridVars');
% else
%     [x0Grid,gridVars] = generateNormalSet( ALPHAS,DS,THETAS,PSIS );
%     save( gridfn, 'x0Grid', 'gridVars')
% end
% 
%  %% Generate Trajectories & Plane
% basePlane = createPlane( GT_D, 0, 0, 1 );
% [baseTraj,~,~,trajSpeeds,trajHeights] = addTrajectoriesToPlane( basePlane, [], NUM_TRAJECTORIES, 2000, meanSpeed, sdSpeed, sdSpdInter, sdDrn, sdHeight);
% 
% rotX = makehgtform('xrotate',-deg2rad(GT_T));
% rotZ = makehgtform('zrotate',-deg2rad(GT_P));
% rotation = rotZ*rotX;
% 
% camPlane = rotation(1:3,1:3)*basePlane;
% camTraj = cellfun(@(x) rotation(1:3,1:3)*x,baseTraj,'uniformoutput',false);
% 
% imPlane = wc2im(camPlane,GT_ALPHA);
% imTraj = cellfun(@(x) traj2imc(wc2im(x,GT_ALPHA),1,1), camTraj,'uniformoutput',false);

%% for each item of the grid, estimate the plane.
fsolve_options

x_iter      =  cell(size(x0Grid,1),1);
fval        =  cell(size(x0Grid,1),1);
exitflag    = zeros(size(x0Grid,1),1);
distances   = zeros(size(x0Grid,1),1);
output      =  cell(size(x0Grid,1),1);

parfor b=1:length(x0Grid)
     [ x_iter{b}, fval{b}, exitflag(b), output{b} ] = fsolve(@(x) traj_iter_func(x, imTraj),[x0Grid(b,:),1],options);
     distances(b) = vector_dist( x0Grid(b,:) , GT_ITER );  
end
 

% find all for which error is less than eps.

% draw plot of euclidean distance of starting point against error?
figure;  scatter(distances(exitflag > 0),cellfun(@(x) sum(x.^2),fval(exitflag > 0)),24,'b');
hold on; scatter(distances(exitflag < 1),cellfun(@(x) sum(x.^2),fval(exitflag < 1)),24,'r');
save expdata_all.mat

