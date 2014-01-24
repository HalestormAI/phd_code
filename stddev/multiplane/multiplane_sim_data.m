NUM_TRAJ = 20;
% % Add noise here
% speeds = cell(NUM_TRAJ,1);
% for t=1:NUM_TRAJ
%     speeds{t} = normrnd(.1,.005,1,2000);
% end
% % speeds(t,:) = num2cell((normrnd(.1,0,10,2000)),2);
% drns = num2cell(deg2rad(normrnd(0,5,NUM_TRAJ,2000)),2);
% global planes;


disp('********************************');

planes
plane_params


disp('********************************');

% Plane_params contains (a,b,c)^\top and d.
[planes,plane_params] = multiplane_make_planes(1, [0,25] );

params = multiplane_params_example( 10, NUM_TRAJ );
params.camera.position = multiplane_camera_position( mean([planes.world],2), params );

traj = multiplane_add_trajectories({planes.world}',plane_params,params.trajectory.speeds,params.trajectory.drns);

[planes,camTraj] = world2camera( planes, traj, params);
[planes,imTraj] = camera2image( planes, camTraj, 1/params.camera.focal);
% figure;
% subplot(1,2,1);
% drawPlane(planes(1).camera,'',0);
% drawPlane(planes(2).camera,'',0,'r');
% drawtraj(camTraj,'',0,'k');
% drawCameraAxis(2);
% axis auto; axis equal;
% 
% subplot(1,2,2);
% drawPlane(planes(1).image,'',0);
% drawPlane(planes(2).image,'',0,'r');
% drawtraj(imTraj,'',0,'k');
% view(0,90);

colours = ['k','r','b','g','m','c'];

drawPlane(planes(1).world);
for p=2:length(planes)
    drawPlane(planes(p).world,'',0,colours(p));
end
% drawPlane(planes(3).world,'',0,'b'); 
axis equal
axis ij
drawtraj( traj,'',0,'b' );