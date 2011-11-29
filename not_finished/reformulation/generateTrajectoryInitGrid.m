function out = generateTrajectoryInitGrid( t_length,grid )
    if nargin < 2,
        grid = generateNormalSet;
    end
    out = [grid,ones(length(grid),t_length)];
end