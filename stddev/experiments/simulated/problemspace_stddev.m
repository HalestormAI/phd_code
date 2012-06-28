% Set up constants for iterator
D = 3;
FOC = 1;

orientations = [ 67,23 ];
scale = [D,FOC];

stddev    = 0;
stddev_w  = 0;

stddev_h  = 0;

NUM_EXPS = length(stddev_hs);

% Init loop parameters
camPlanes     = cell(NUM_EXPS,length(orientations));
imPlanes      = cell(NUM_EXPS,length(orientations));
camTrajs      = cell(NUM_EXPS,length(orientations));
imTrajs       = cell(NUM_EXPS,length(orientations));

plane_details = createPlaneDetails( orientations, scale, [stddev,stddev_w, stddev_h] );
GT_N = normalFromAngle( orientations(1), orientations(2) );

camPlane  = plane_details.camPlane;
imPlane   = plane_details.imPlane;
camTraj   = plane_details.camTraj;
imTraj    = plane_details.trajectories;

thetas = 1:90;
psis = -60:60;
focals = FOC;

[fullErrors,minErrors,E_angles,E_focals, inits] = iterator_parfor_foc( D, plane_details,thetas,psis,focals);

xs = inits(:,1);
ys = inits(:,2);
zs = fullErrors;
figure;
scatter3(xs,ys,zs,24,'*b');
xlabel('Angle of Elevation, \theta');
ylabel('Angle of Yaw, \psi');
zlabel('SSD Error');


save problemspace
