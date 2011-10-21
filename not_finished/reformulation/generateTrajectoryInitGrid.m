function out = generateTrajectoryInitGrid( t_length )
    grid = generateNormalSet;
    out = [grid,ones(length(grid),t_length)];
end