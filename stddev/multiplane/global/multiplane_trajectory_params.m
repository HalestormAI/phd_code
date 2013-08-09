function params = multiplane_trajectory_params( speeds, drns, params )
% Creates parameters for trajectory creation, namely speed and direction
% variations.
%
% Input:
%   speeds      A Tx1 cell array, with each cell containining a vector of 
%               frame-by-frame speeds
%   directions  As above, but for direction
%   [params]    An existing parameters structure. Optional
%
% Output:
%   A parameters structure containing the speed and directions cell-arrays.
%   If the `params` argument was given, these are appended to the existing
%   structure.

    if nargin < 3
        params = [];
    end
    
    params.trajectory.speeds = speeds;
    params.trajectory.drns = drns;
end