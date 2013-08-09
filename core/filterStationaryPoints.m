function traj_filtered = filterStationaryPoints( traj, threshold )
    % Filters out all trajectories which show motion of less than 
    % `threshold` pixels in either direction component.
    %
    % Input:
    %   traj        Cell array of trajectories
    %   threshold   Minimum px motion to accept in either direction
    %               component. [default=eps]
    
    if nargin < 2
        threshold = eps;
    end
    moved = cellfun(@(x) sum(range(x')) > threshold,traj);
    traj_filtered = traj(moved);
end
    
    