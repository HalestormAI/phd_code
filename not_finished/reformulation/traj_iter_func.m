function F = traj_iter_func( x, trajectories )
    
    % get lengths of all trajectories and sum to predefine array
    lengths = cellfun(@length,trajectories)./2;
    
    F = zeros(1,sum(lengths));

    F(1:lengths(1)) = traj_F( trajectories{1}, 1, x, 1 );
    curLength = lengths(1);
    for t = 2:length(trajectories),
        F(curLength+1:curLength+lengths(t)) = traj_F( trajectories{t}, t, x, 0 );
        curLength = curLength+lengths(t);
    end
    
    
end