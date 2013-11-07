function params = multiplane_params_example( height, NUM_TRAJ, scale, TIME )
% Generates a set of  plane parameters with the following specification:
%   Camera:
%       Rotation: AOE=30 degrees and AOY = 5 degrees.
%       Focal length: 720.
%
%   Trajectory (2000 frames):
%    	Speeds: Based on N(scale,0) distribution. For details of `scale`
%               see INPUT.
%       Directions: Based on N(0,5)
%
% INPUT:
%   scale           The scale of the plane structure in world-coordinates
%   [NUM_TRAJ=30]   The max. number of trajectories to generate. Optional.

    if nargin < 2
        NUM_TRAJ = 30;
    end
    
    if nargin < 3 || isempty(scale)
        scale = 1/height;
    end
    
    if nargin < 4
        TIME = 2000;
    end

    params = multiplane_cam_params( 30, 15, 720, height );
    
    speeds = cell(NUM_TRAJ,1);
    for t=1:NUM_TRAJ
        speeds{t} = normrnd(scale,.0,1,TIME);
    end
    % speeds(t,:) = num2cell((normrnd(.1,0,10,2000)),2);
    drns = num2cell(deg2rad(normrnd(0,5,NUM_TRAJ,TIME)),2);
    
    params = multiplane_trajectory_params( speeds, drns, params );
end