matlabpool close;

FIXED_D = 1;

%% Set up initial parameters
MODE_ALL_PARAM = 1; % Use all regions' estimated params as hypotheses
MODE_CLUSTER_K = 2; % Throw all into kmeans and cluster for 2 of them
MODE_CLUSTER_G = 3; % Use gmeans to more intelligently cluster

WINDOW_SIZE = 100;
WINDOW_DISTANCE = WINDOW_SIZE/2;

ML = 2;
STEP = 10;


NOISE_LEVEL = 0;

params = multiplane_params_example(9,45,[],[], NOISE_LEVEL);
params.camera.focal = 2100;

ANGLES = 1:2:40;


ANGLE_HYPOTHESES = cell(length(ANGLES),1);
ANGLE_GROUNDTRUTH = cell(length(ANGLES),1);

% Find the estimated plane boundaries
for a=1:length(ANGLES)
    
    % Generate hypotheses for each region using the combined solver
    
    
    save_data = struct();
    save_data.angle = ANGLES(a);
    save_data.timestamp = datestr(now,'yyyy-mm-dd HH-MM-SS');
    save_data.params = params;
    save_data.noise = NOISE_LEVEL;
    
    if ~exist('wavefront_fn','var')
        planes = multiplane_random_plane_generator( 2, ANGLES(a));
    end
    
    [planes, trajectory_struct] = multiplane_process_world_planes( planes, params );
    
    save_data.planes = planes;
    flattening_save(sprintf('flattening_data_a-%d.mat',ANGLES(a)),save_data);
    
    imTraj = trajectory_struct.image;
    
    
    %% Generate Initial Regions
    mm = minmax([imTraj{:}]);
    regions = multiplane_gen_sliding_regions(mm, WINDOW_SIZE, imTraj, WINDOW_DISTANCE);
    % abs(mm(1,1)-mm(1,2))
    
    empties = arrayfun(@(x) isempty(x.traj), regions);
    regions = arrayfun( @addemptyfield, regions, empties);
    
    ground_truth = zeros(length(planes),2);
    for p=1:length(planes)
        ground_truth(p,:) = anglesFromN(planeFromPoints(planes(p).camera),1,'degrees');
    end
    ANGLE_GROUNDTRUTH{a} = ground_truth;
    
    [ output_params ] = multiplane_combined_solver( regions,abs(mm(1,1)-mm(1,2)),ML,STEP );
    
    output_params = multiplane_filter_output_params( output_params );
    
    hypotheses = gmeans(output_params,0.001,'pca','ad');
    ANGLE_HYPOTHESES{a} = hypotheses;
    
    disp('GROUND TRUTH:');
    disp(ground_truth)
    
    disp('HYPOTHESES:');
    disp(hypotheses)
    
    save_data.output_params = output_params;
    save_data.hypotheses = hypotheses;
    save_data.ground_truth = ground_truth;
    flattening_save(sprintf('flattening_data_a-%d.mat',ANGLES(a)),save_data);
    
end