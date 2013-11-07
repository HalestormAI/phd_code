function new_traj = rectify_trajectories( trajs, T )

    new_traj = cellfun(@(x) rect( x, T ), trajs, 'un', 0);
    function t = rect( t,T )
        t3 = T*makeHomogenous(t);
        t(1,:) = t3(1,:) ./ t3(3,:);
        t(2,:) = t3(2,:) ./ t3(3,:);
    end

end
