% 
% % % % OLD STUFF - IGNORE THIS!
% % % % %% Init Params
% % % %     NUM_ITERATIONS = 2;
% % % % 
% % % %     MODE_ALL_PARAM = 1; % Use all regions' estimated params as hypotheses
% % % %     MODE_CLUSTER_2 = 2; % Throw all into kmeans and cluster for 2 of them
% % % %     MODE_CLUSTER_G = 3; % Use gmeans to more intelligently cluster
% % % % 
% % % %     WINDOW_SIZE = 100;
% % % %     WINDOW_DISTANCE = 50;
% % % % 
% % % % 
% % % %     MODE = MODE_CLUSTER_2;
% % % %
% % %     FIXED_D = 1;
% % % % 
% % % % %% Setup simulated data
% % % %     multiplane_sim_data;
% % % % 
% % % % %% Get region data
% % % %     allPoints = [imTraj{:}];
% % % %     mm = minmax([imTraj{:}]);
% % % %     regions = multiplane_gen_sliding_regions(mm, WINDOW_SIZE, imTraj, WINDOW_DISTANCE);
% % % % 
% % % % %% Produce initial region estimates
% % % %     output_params = cell(length(regions),1);
% % % %     finalError    = cell(length(regions),1);
% % % %     fullErrors    = cell(length(regions),1);
% % % %     inits         = cell(length(regions),1);
% % % % 
% % % % 
% % % % 
% % % %     for r=1:length(regions)
% % % %         fprintf('Region: %d\n',r);
% % % %         if length(regions(r).traj) < 1
% % % %             regions(r).empty = 1;
% % % %             fprintf('\tNo trajectories in region\n');
% % % %             continue;
% % % %         end
% % % %         regions(r).empty = 0;
% % % %         plane_details(r).trajectories = traj2imc( regions(r).traj,1,1 );
% % % %         plane_details(r).imagewidth = abs(mm(1,2) - mm(1,1));
% % % %         [ output_params{r}, finalError{r}, fullErrors{r}, inits{r} ] = multiplane_multiscaleSolver_using_imagewidth( 1, plane_details(r), 3, 10, 1e-12 );
% % % %     end
% % % % 
% % % %     disp('ESTIMATES');
% % % %     output_mat = cell2mat(output_params);
% % % % 
% % % %     if abs(round(output_mat(1,2))) == 101 || abs(round(output_mat(2,2))) == 101
% % % %         disp('Error101');
% % % %         save( sprintf('error101_iteration-%d_region-%d_%s',iteration,r,datestr(now, '_dd-mm-yy_HH-MM-SS')) );
% % % %     end
% % % % 

FIXED_D = 1;

combined_alpha_est_data;

empties = arrayfun(@(x) isempty(x.traj), regions);
regions = arrayfun( @addemptyfield, regions, empties);

plane_details = struct('trajectories',{},'imagewidth',{});
for r=1:length(regions)
    plane_details(r).trajectories = traj2imc( regions(r).traj,1,1 );
    plane_details(r).imagewidth = abs(mm(1,2) - mm(1,1));
end

if MODE == MODE_CLUSTER_2
    [~,hypotheses] = kmeans(output_params,2);
elseif MODE == MODE_CLUSTER_G
    hypotheses = gmeans(output_params,0.001,'pca','gamma');
else
    hypotheses = output_params;
end



% Output estimation details.
% [plane_ids,confidence] = multiplane_planeids_from_traj( planes, tmpTraj );
disp('GROUND TRUTH');
ground_truth(1,:) = anglesFromN(planeFromPoints(planes(1).camera),1,'degrees')
ground_truth(2,:) = anglesFromN(planeFromPoints(planes(2).camera),1,'degrees')



%% Get the initial labelling
labelCost = NaN.*ones(size(hypotheses,1),length(regions));
for e=1:size(hypotheses,1)
    for r=1:length(regions)
        labelCost(e,r) = sum(errorfunc( hypotheses(e,1:2), [1,hypotheses(e,3)], traj2imc(regions(r).traj,1,1)).^2);
    end
end


[~,MINIDS] = min(labelCost);

%% Relabel using SVM
svm_line_splitter;
% 
% 
% %% Use SVM labelling to get plane edge constraint
% % TODO: Get trajectory endpoints that intersect with the SVM line - we know
% % these to be on the plane.
%     % reorder hypotheses
    ordered_hypotheses = assign_hypotheses_for_regions(hypotheses,regions);
% 
%     % Get plane dividing line endpoints for constraint
    svm_line = [xvals(~isnan(xvals)),yvals(~isnan(yvals))]';
    plane_constraints_im = svm_line(:,[1,end]);
%     
%     % Get the points on in trajectories that hit the dividing line
% %     region_endpoints = cell2mat(cellfun(@(x) x(:,[1 end]), regions(1).traj,'un',0));
% %     region_online = cellfun(@(x) is_point_on_line(x,plane_constraints_im,1),num2cell(region_endpoints,1));
% %     
% %     if find(region_online)
% %         plane_constraints_im = region_endpoints(:,region_online)
% %     end
% 
%     % Rectify with plane 1 hypothesis
%     plane_constraints_rect = backproj_c( ordered_hypotheses(1,1), ...
%                                          ordered_hypotheses(1,2), ...
%                                          FIXED_D, ...
%                                          ordered_hypotheses(1,3), ...
%                                          plane_constraints_im ...
%                                        );


% plane_constraints_im = p

%% Now have our 2 3d points that should be constrained. Need to search given
%  new equation
%  N.B. can use backproj as before - just vary different parameters

    % set plane details to reflect regions
    imagewidth = max([plane_details.imagewidth]);
    clear plane_details;
    plane_details = struct('trajectories',{regions.traj},'imagewidth',imagewidth)


constraints_3d = backproj_c( ordered_hypotheses(1,1), ...
                          ordered_hypotheses(1,2), ...
                          FIXED_D, ...
                          ordered_hypotheses(1,3), ...
                          plane_constraints_im ...
                        )

[ plane2.output_params, plane2.finalError, plane2.fullErrors, plane2.inits, plane2.E_angles, plane2.E_focals, plane2.errorvecs ] = multiplane_hinged_solver( plane_details(2), constraints_3d, ordered_hypotheses(1,3), FIXED_D, 3, 10, 1e-12 );

% Update ordered hypothesis with new plane2 data and d
% Now: [ t_i, p_i, a_i, d_i ], where i in {1,2}
ordered_hypotheses(:,4) = [1;plane2.output_params(3)]
ordered_hypotheses(2,1:2) = plane2.output_params(1:2)

% rectify each plane with the hypothesis
traj_rectified{1} = cellfun(@(x) backproj_c( ordered_hypotheses(1,1), ordered_hypotheses(1,2), ordered_hypotheses(1,4), ordered_hypotheses(1,3), x ), plane_details(1).trajectories, 'un', 0);
traj_rectified{2} = cellfun(@(x) backproj_c( ordered_hypotheses(2,1), ordered_hypotheses(2,2), ordered_hypotheses(2,4), ordered_hypotheses(2,3), x ), plane_details(2).trajectories, 'un', 0);

[~,d1] = planeFromPoints(planes(1).camera);
[~,d2] = planeFromPoints(planes(2).camera);

gt_params(1,:) = [ ground_truth(1,:), 0.0014, 1 ];
gt_params(2,:) = [ ground_truth(2,:), 0.0014, d2/d1 ];

gt_params_ordered = assign_hypotheses_for_regions(gt_params,regions);

traj_gt{1} = cellfun(@(x) backproj_c( gt_params_ordered(1,1), gt_params_ordered(1,2), gt_params_ordered(1,4), gt_params_ordered(1,3), x ), plane_details(1).trajectories, 'un', 0);
traj_gt{2} = cellfun(@(x) backproj_c( gt_params_ordered(2,1), gt_params_ordered(2,2), gt_params_ordered(2,4), gt_params_ordered(2,3), x ), plane_details(2).trajectories, 'un', 0);

%% Match up gt and estimated planes so they can be compared based on centroids
% find centroids of planes and trajectories
for i=1:length(planes)
    plane_centroids(:,i) = mean(planes(i).image,2);
end
for i=1:length(plane_details)
    traj_centroids(:,i) = mean([plane_details(i).trajectories{:}],2);
end

% Now associate plane with traj by image centroid
centroid_distances = pdist2( traj_centroids', plane_centroids' );
[~,best_match] = min(centroid_distances);

constraints_gt = backproj_c( gt_params_ordered(1,1), ...
    gt_params_ordered(1,2), ...
    gt_params_ordered(1,4), ...
    gt_params_ordered(1,3), ...
    plane_constraints_im ...
);

%% Plot a load of stuff to help work out what in the name of all that's holy what is going on...
figure;
subplot(1,2,1)
drawtraj(traj_gt{1},'',0);
drawtraj(traj_gt{2},'Ground Truth',0,'r');
plot3( constraints_gt(1,:),constraints_gt(2,:),constraints_gt(3,:),'b-','LineWidth',2);
axis auto;
p_ax(1,:) = axis;

subplot(1,2,2)
drawtraj(traj_rectified{1},'',0);
drawtraj(traj_rectified{2},'Estimated',0,'r');
plot3( constraints_3d(1,:),constraints_3d(2,:),constraints_3d(3,:),'b-','LineWidth',2);
axis auto;
p_ax(2,:) = axis;

% Normalise axes
new_ax = interleave(min(p_ax(:,[1:2:end])), max(p_ax(:,[2:2:end])));
subplot(1,2,1); axis(new_ax); view(-42,12);
subplot(1,2,2); axis(new_ax); view(-42,12);
