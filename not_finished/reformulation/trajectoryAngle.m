function angle = trajectoryAngle( traj )

    % get generalised direction of vector
    drn = traj(:,1) - traj(:,end);

    angle = angleError( [0;1], drn );
    if drn(1) < 0
        angle = angle+180;
    end
end