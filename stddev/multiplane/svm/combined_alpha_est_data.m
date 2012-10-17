%% Set up initial parameteres
MODE_ALL_PARAM = 1; % Use all regions' estimated params as hypotheses
MODE_CLUSTER_2 = 2; % Throw all into kmeans and cluster for 2 of them
MODE_CLUSTER_G = 3; % Use gmeans to more intelligently cluster

WINDOW_SIZE = 100;
WINDOW_DISTANCE = 50;


MODE = MODE_CLUSTER_2;

multiplane_sim_data;

allPoints = [imTraj{:}];

%% Display ground truth
disp('GROUND TRUTH');
ground_truth(1,:) = anglesFromN(planeFromPoints(planes(1).camera),1,'degrees')
ground_truth(2,:) = anglesFromN(planeFromPoints(planes(2).camera),1,'degrees')


%% Generate Initial Regions
mm = minmax([imTraj{:}]);
regions = multiplane_gen_sliding_regions(mm, WINDOW_SIZE, imTraj, WINDOW_DISTANCE);
% abs(mm(1,1)-mm(1,2))
    
%% Produce region estimations
[ output_params, E_thetas E_psis, E_focals ] = multiplane_combined_solver( regions,abs(mm(1,1)-mm(1,2)) );

% %% Get the initial labelling
% labelCost = NaN.*ones(size(hypotheses,1),length(regions));
% for e=1:size(hypotheses,1)
%     for r=1:length(regions)
%         labelCost(e,r) = sum(errorfunc( hypotheses(e,1:2), [1,hypotheses(e,3)], traj2imc(regions(r).traj,1,1)).^2);
%     end
% end
% 
% 
% [~,MINIDS] = min(labelCost);
% 
% %% Relabel using SVM
% svm_line_splitter;