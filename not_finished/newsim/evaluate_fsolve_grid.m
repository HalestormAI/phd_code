%% SET PARAMETERS HERE
theta = 17;
psi = -27;
FOCAL = 23;

load grid grid;
%% Move into dir
setup_exp;

%% Create planes and trajectories
basePlane = createPlane( 18, 0, 0, 10 );
baseTraj = addTrajectoriesToPlane( basePlane, [], 10, 2000, 1, 0, 0, 5);


rotX = makehgtform('xrotate',deg2rad(-theta));
rotZ = makehgtform('zrotate',deg2rad(-psi));
rotation = rotZ*rotX;

GT_N = -rotation(1:3,3);

camPlane = rotation(1:3,1:3)*basePlane;
camTraj = cellfun(@(x) rotation(1:3,1:3)*x,baseTraj,'uniformoutput',false);

imPlane = wc2im(camPlane,-1/FOCAL);
imTraj = cellfun(@(x) traj2imc(wc2im(x,-1/FOCAL),1,1), camTraj,'uniformoutput',false);


%% Run iteration
x0s = generateTrajectoryInitGrid( length(baseTraj), grid );

fsolve_options

x_iter      =  cell(size(x0s,1),1);
fval        =  cell(size(x0s,1),1);
exitflag    = zeros(size(x0s,1),1);
output      =  cell(size(x0s,1),1);
disp('Optimising');
solveTic = tic;
parfor b=1:length(x0s)
%                 fprintf('\tInitial Estimate %d of %d\n',b, length(tobeoptimised_x0));
[ x_iter{b}, fval{b}, exitflag(b), output{b} ] = fsolve(@(x) traj_iter_func(x, imTraj),x0s(b,:),options);
end


%% Post-processing
[~,post_SIDS] = sort(cellfun(@(x) sum(x.^2),fval));

MAYBE = cell2mat(x_iter(post_SIDS(1:10)));
OUTPUT_NS = cell2mat(cellfun(@(x) abc2n(x(1:3)), num2cell(MAYBE,2),'uniformoutput',false));

ANGLE_ERRORS = cellfun( @(x) acos(dot(x',GT_N)),num2cell(OUTPUT_NS,2));
ITERATION_ERROR = cell2mat(fval(post_SIDS(1:10)));

%% Plotting
drawPlane( camPlane ,'',1,'r');
cellfun(@(x) drawcoords3(x, '',0,'r'),camTraj);

drawbadestimates;

ALL_NS = cell2mat(cellfun(@(x) abc2n(x(1:3)), x_iter(exitflag > 0),'uniformoutput',false));
ALL_ANGLE_ERRORS = cellfun( @(x) acos(dot(x',GT_N)),num2cell(ALL_NS,2));
figure;scatter(log10(sum(cell2mat(fval(exitflag > 0)).^2,2)),ALL_ANGLE_ERRORS);
xlabel('log_{10}(fval)');
ylabel('Plane-Normal Error (radians)');
saveas( f,'fval_vs_angle.fig' )
save expdata;