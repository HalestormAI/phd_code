function outTraj = filterTrajectoryLengths( trajectories, MIN_LENGTH )

    if nargin < 2
        MIN_LENGTH = 2;
    end
    lengths = cellfun(@length,trajectories);
    empties = cellfun(@isempty,trajectories);
    lengths(empties) = 0;
    outTraj = trajectories(lengths >= MIN_LENGTH);
end