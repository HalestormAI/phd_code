% Set up constants for iterator
D = 3;
FOC = 1;

orientations = [ 65,25 ];
scale = [D,FOC];

stddev    = 0;
stddev_w  = 0;
stddev_h  = 0;


plane_details = createPlaneDetails( orientations, scale, [stddev,stddev_w, stddev_h] );

camPlane  = plane_details.camPlane;
imPlane   = plane_details.imPlane;
camTraj   = plane_details.camTraj;
imTraj    = plane_details.trajectories;

thetas = 1:5:90;
psis = -60:5:60;
focals = FOC;

[fullErrors,minErrors,E_angles,E_focals, inits] = iterator_parfor_foc( D, plane_details,thetas,psis,focals);

xs = inits(:,1);
ys = inits(:,2);
zs = fullErrors;
figure;
scatter3(xs,ys,log10(zs),24,'*b');
xlabel('Angle of Elevation, $\theta$');
ylabel('Angle of Yaw, $\psi$');
zlabel('SSD Error');
plotCross([65,25,log10(minErrors)])


save problemspace
