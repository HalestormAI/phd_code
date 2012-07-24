
speeds = num2cell((normrnd(.1,0,10,2000)),2);
drns = num2cell(deg2rad(normrnd(0,10,10,2000)),2);

[planes,plane_params] = multiplane_make_planes( );

traj = multiplane_add_trajectories({planes.world}',plane_params,speeds,drns);
[planes,camTraj] = world2camera( planes, traj, [25,15]);
[planes,imTraj] = camera2image( planes, camTraj, -1/720 );
figure;
subplot(1,2,1);
drawPlane(planes(1).camera,'',0);
drawPlane(planes(2).camera,'',0,'r');
drawtraj(camTraj,'',0,'k');
drawCameraAxis(2);
axis auto; axis equal;

subplot(1,2,2);
drawPlane(planes(1).image,'',0);
drawPlane(planes(2).image,'',0,'r');
drawtraj(imTraj,'',0,'k');
view(0,90);