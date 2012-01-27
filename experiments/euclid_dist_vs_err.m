% Given clean data, how far away can we start and still find happiness?
fixAngle = @(x) pi/2 - abs(pi/2- x);
setup_exp;

%% Experiment Parameters
meanSpeed  = 1;
sdSpeed    = 0;
sdSpdInter = 0;
sdHeight   = 0;
sdDrn      = 15;

ALPHAS = -10.^(-3:1:-1);
THETAS = 0:10:90;
PSIS   = -60:10:60;
DS = 1:5:20;

NUM_TRAJECTORIES = 1;
GT_T = 17;
GT_P = 30;
GT_D = 10;

GT_N = normalFromAngle( GT_T,GT_P );
GT_ALPHA = -0.0025;

GT_ITER = [n2abc(GT_N,GT_D)',GT_ALPHA];

gridfn = 'fine_grid.mat';
if exist(gridfn,'file')
   load( gridfn, 'x0Grid', 'gridVars');
else
    [x0Grid,gridVars] = generateNormalSet( ALPHAS,DS,THETAS,PSIS );
    save( gridfn, 'x0Grid', 'gridVars')
end

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

%% for each item of the grid, estimate the plane.
fsolve_options

x_iter      =  cell(size(x0Grid,1),1);
fval        =  cell(size(x0Grid,1),1);
exitflag    = zeros(size(x0Grid,1),1);
distances   = zeros(size(x0Grid,1),1);
errors      = zeros(size(x0Grid,1),1);
angleErrors = zeros(size(x0Grid,1),1);
output      =  cell(size(x0Grid,1),1);

numelem = length(x0Grid);

parfor b=1:length(x0Grid)
     [ x_iter{b}, fval{b}, exitflag(b), output{b} ] = fsolve(@(x) traj_iter_func(x, imTraj),[x0Grid(b,:),1],options);
     distances(b) = vector_dist( x0Grid(b,:) , GT_ITER );  
     errors(b) = sum(fval{b}.^2);
     angleErrors(b) = angleError( abc2n(x_iter{b}(1:3)), abc2n(GT_ITER(1:3)),0, 'radians');
     if mod(b,50) == 0
         fprintf('Iteration %d of %d\n',b, numelem);
     end
end
 

% find all for which error is less than eps.

% draw plot of euclidean distance of starting point against error?
f = figure;  
hold on; 
scatter(distances(exitflag < 1),log10(errors(exitflag < 1)),24,'r');
scatter(distances(exitflag > 0),log10(errors(exitflag > 0)),24,'b');
xlabel('Euclidean Distance Between x0 and ground-truth');
ylabel('log_{10} of fval error');
saveas(f,'x0dist_vs_fvalerr.fig');
f = figure;  
hold on; 
scatter(distances(exitflag < 1),angleErrors(exitflag < 1),24,'r');
scatter(distances(exitflag > 0),angleErrors(exitflag > 0),24,'b');
xlabel('Euclidean Distance Between x0 and ground-truth');
ylabel('Angle error (radians)');
saveas(f,'x0dist_vs_angleerr.fig');
save expdata_all.mat
f = figure;  
hold on; 
scatter3(log10(errors(exitflag < 1)),angleErrors(exitflag < 1),distances(exitflag < 1),24,'r*');
scatter3(log10(errors(exitflag > 0)),angleErrors(exitflag > 0),distances(exitflag > 0),24,'b*');
xlabel('log_{10} of fval error');
ylabel('Angle error (radians)');
zlabel('Euclidean Distance Between x0 and ground-truth');
grid on;
saveas(f,'x0dist_vs_botherr.fig');
save expdata_all.mat
