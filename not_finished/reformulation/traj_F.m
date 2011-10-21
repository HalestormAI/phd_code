
    function tF = traj_F( traj, idx, x, isfirst )
        tF = zeros(1,length(traj)/2);
        for i=1:2:length(traj)
            tF((i+1)/2) = traj_dist_eqn( x, traj(:,i:i+1),  idx, isfirst );
        end
    end