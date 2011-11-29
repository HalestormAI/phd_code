function F = traj_iter_func( x, trajectories )
    
    F = zeros(length(trajectories),1);
    
    F(1) = mean(traj_F( trajectories{1}, 1, x, 1 ));
    for t = 2:length(trajectories),
        F(t) = mean(traj_F( trajectories{t}, t, x, 0 ));
    end
    
    
end