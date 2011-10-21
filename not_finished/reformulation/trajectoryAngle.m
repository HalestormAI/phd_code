function angle = trajectoryAngle( traj )

% get generallised direction of vector
drn = abs(traj(:,1) - traj(:,end));

angle = angleError( [0;1], drn );

end