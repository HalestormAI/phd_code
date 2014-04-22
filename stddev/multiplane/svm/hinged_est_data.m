% 
% FIXED_D = 1;
% 
% %% Set up initial parameters
% MODE_ALL_PARAM = 1; % Use all regions' estimated params as hypotheses
% MODE_CLUSTER_K = 2; % Throw all into kmeans and cluster for 2 of them
% MODE_CLUSTER_G = 3; % Use gmeans to more intelligently cluster
% 
% WINDOW_SIZE = 30;
% WINDOW_DISTANCE = WINDOW_SIZE/2;
% 
% pcolours = repmat(['k','r','b','g','m','c','y'],1,6);
% 
% rootFld = sprintf('hinged-%s-winsz_%d-windist_%d',datestr(now,'HH-MM-SS'), WINDOW_SIZE, WINDOW_DISTANCE);
% mkdir(rootFld);
% pushd( rootFld );
% 
% MODE = MODE_CLUSTER_K;
% 
% params = multiplane_params_example(10,45,[],[], 0.0);
% 
% if ~exist('wavefront_fn','var')
%     planes = multiplane_random_plane_generator( 2, [-35]);
% end
% 
% 
% if exist('wavefront_fn','var')
%     % multiplane_sim_data;
%     % If want ot use wavefront file, use '/home/ian/PhD/equal-plane-sizes.obj'
%     [planes, trajectory_struct, params, plane_params] = multiplane_read_wavefront_obj( wavefront_fn, params,1 );
% else
% %     load ../tplanes;
%     [planes, trajectory_struct, params, plane_params] = multiplane_process_world_planes( planes, params );
% end
% 
% camTraj = trajectory_struct.camera;
% imTraj = trajectory_struct.image;
% allPoints = [imTraj{:}];
% 
% 
% save('input_data');
% % figure;
% % subplot(1,2,1)
% % drawPlanes(planes,'world',0,pcolours);
% % drawtraj(trajectory_struct.world,'',0,'k');
% % draw_camera_pyramid( params, .5, .5, 1)
% % axis auto;
% % subplot(1,2,2);
% % drawPlanes(planes,'image',0,pcolours);
% % drawtraj(trajectory_struct.image,'',0,'k');
% % return
% 
% % pause
% %% Generate Initial Regions
% mm = minmax([imTraj{:}]);
% regions = multiplane_gen_sliding_regions(mm, WINDOW_SIZE, imTraj, WINDOW_DISTANCE);
% % abs(mm(1,1)-mm(1,2))
% 
% empties = arrayfun(@(x) isempty(x.traj), regions);
% regions = arrayfun( @addemptyfield, regions, empties);
% 
% 
% restimate(1).regions = regions;
% pixel_regions = multiplane_gen_sliding_regions(mm, WINDOW_SIZE, imTraj, 2);
% pempties = arrayfun(@(x) isempty(x.traj), pixel_regions);
% pixel_regions = arrayfun( @addemptyfield, pixel_regions, pempties);
% 
% 
% region_dims = ceil(range(ceil(mm'))./WINDOW_DISTANCE);
% % Output estimation details.
% % [plane_ids,confidence] = multiplane_planeids_from_traj( planes, tmpTraj );
% disp('GROUND TRUTH');
% for p=1:length(planes)
%     ground_truth(p,:) = anglesFromN(planeFromPoints(planes(p).camera),1,'degrees');
% end
% disp(ground_truth)
% 
% MAX_ITERATIONS = 1;
% pcolours = ['k','r','b','g','m','c','y'];
% 
% BOUNDARY_METHOD = 'SVM';
% 
% save input_data;
% 
% 
% % Find the estimated plane boundaries
% for iteration=1:MAX_ITERATIONS
%     if iteration > 1
%         % Generate hypotheses for each region using the combined solver
%         if iteration == 1
%             ML = 2;
%             STEP = 10;
%         else
%             ML = 3;
%             STEP = 5;
%         end
%         
%         [ output_params, E_thetas, E_psis, E_focals ] = multiplane_combined_solver( restimate(iteration).regions,abs(mm(1,1)-mm(1,2)),ML,STEP );
%         
%         restimate(iteration).solver.output_params = output_params;
%         restimate(iteration).solver.E_thetas = E_thetas;
%         restimate(iteration).solver.E_psis = E_psis;
%         restimate(iteration).solver.E_focals = E_focals;
%         
%         if iteration == 1
%             output_params = multiplane_filter_output_params( output_params );
%         end
%         
%         if iteration > 1
%             MODE = MODE_ALL_PARAM;
%         end
%         
%         % Cluster these into a number of known planes
%         if MODE == MODE_CLUSTER_K
%             while 1
%                 try % If we have 2 planes with same orientation, K-Means gets empty clusters, try reducing K by one.
%                     [~,hypotheses] = kmeans(output_params,length(planes));
%                     break;
%                 catch err
%                     disp('empty cluster, trying again');
%                 end
%             end
%         elseif MODE == MODE_CLUSTER_G
%             hypotheses = gmeans(output_params,0.001,'pca','ad');
%         else
%             hypotheses = output_params;
%         end
%         hypotheses(any(isnan(hypotheses')),:) = []; % Remove dropped clusters
%         hypotheses
%         restimate(iteration).hypotheses = hypotheses;
%         save(sprintf('hypotheses_%d.mat',iteration));
%     
%         % Use the 1px sliding window regions 1 to generate the error matrix for this iteration
%         labelCost = multiplane_calculate_label_cost( pixel_regions, hypotheses );
%         restimate(iteration).labelCost = labelCost;
%         
%         [mincosts,labelling_prealpha] = min(labelCost);
%         
%         
%     %
%     %     if iteration == 1
%     %         fig_prealpha = figure;
%     %         pcolours = ['k','r','b','g','m','c','y'];
%     %         for i=1:length(planes)
%     %             drawPlane(planes(i).image, '' ,0, pcolours(i));
%     %         end
%     %         drawtraj(imTraj,'',0);
%     %         [~,restimate(iteration).regions] = multiplane_overlay_sliding_regions( restimate(iteration).regions, labelling_prealpha);
%     %
%     %         saveas(fig_prealpha,sprintf('regions_iteration-%d.fig',iteration));
%     %     end
%         end
%         if strcmp(BOUNDARY_METHOD,'error') || strcmp(BOUNDARY_METHOD, 'e')
%             boundary_pts = find_boundaries_from_error( pixel_regions, planes, min(restimate(iteration).labelCost), 2 );
%         else
%             [~,linePoints] = multiplane_multiclass_svm(pixel_regions, hypotheses, labelCost,region_dims,planes);
% 
%             boundary_pts = cell(length(linePoints),1);
%             for l =1:length(linePoints)
%                 boundary_pts{l} = linePoints{l}([1 end],:)';
%             end
%         end
%     [region_trajectories, plane_regions, plane_graph] = multiplane_boundary_trajectory_split( trajectory_struct.image, boundary_pts, plane_regions, plane_graph );
%     
%     drawPlanes(plane_regions,'image',1,pcolours)
%     
%     
%     drawPlanes(planes,'image',0,pcolours,'--')
%     
%     % Create regions for next iteration
%     for r=1:length(plane_regions)
%         drawtraj(region_trajectories{r},'',0,pcolours(r));
%         restimate(iteration+1).regions(r).traj = region_trajectories{r};
%     end
%     
%     restimate(iteration+1).plane_graph = plane_graph;
%     
%     empties = arrayfun(@(x) isempty(x.traj), restimate(iteration+1).regions);
%     regions = arrayfun( @addemptyfield, restimate(iteration+1).regions, empties);
% 
% end
% 
% 
% % work out which hypotheses best fit which region
% relabel_cost = multiplane_calculate_label_cost( regions, hypotheses );
% [~,hypothesis_assignment] = min(relabel_cost);
% hypotheses = hypotheses(hypothesis_assignment,:);
% save iterative_boundary_estimation_data_gt
% 
% root_hypothesis = hypotheses(1,:);
% 
% 
% % get initial condition from angles betweeen existing planes.
% init_angles = hinged_initial_condition( hypotheses,plane_graph );
% % init_angles = [31 20]
% % use fsolve on hinged error func
% fsolve_options;
% options = optimset('TolFun',1e-4);
% regions,plane_graph,boundary_pts,root_hypothesis
% [output_angles,fval,exitflag,output] = fsolve(@(x) hinged_errorfunc( regions,plane_graph,boundary_pts,x,root_hypothesis),init_angles,options);
% output_angles

[regions, boundaries_3d] = hinged_reconstruction( root_hypothesis, init_angles, boundary_pts, plane_graph, regions )

figure;
pcolours = ['k','r','b','g','m','c','y'];
for r=1:length(regions)
    rPts = [regions(r).reconstructed{:}];
    hIdx = convhull(rPts(1,:),rPts(2,:),rPts(3,:));
    
        scatter3(rPts(1,:),rPts(2,:),rPts(3,:), 24, strcat('*',pcolours(r)))
    hold on
        pause
    [rotmat,cornerpoints]  = minboundbox(rPts(1,:), rPts(2,:),rPts(3,:),'v',1);
        plotminbox(cornerpoints,pcolours(r));
    drawtraj(regions(r).reconstructed,'',0,pcolours(r))
end
axis equal
grid on

alltrajest = vertcat(regions.reconstructed);
meanlengths_est = cellfun(@(x) nanmean(vector_dist(traj2imc(x,1,1))), alltrajest);
meanlengths_gt = cellfun(@(x) nanmean(vector_dist(traj2imc(x,1,1))), trajectory_struct.camera);
tscale = nanmean(meanlengths_est) / nanmean(meanlengths_gt);


final_params = params;
focal_point = mean([alltrajest{:}],2);
final_params.camera.rotation= -params.camera.rotation;
final_params.camera.height=vector_dist([0;0;0],focal_point);
final_params.camera.position = multiplane_camera_position(focal_point, final_params);

save('output_data');


figure;
subplot(1,2,1)
drawtraj(cellfun(@(x) x.*tscale, trajectory_struct.camera,'un',0),'',0,'k');
draw_camera_pyramid( final_params, tscale, tscale, 2*tscale )
axis equal
grid on
axis auto
subplot(1,2,2)
drawtraj(alltrajest,'',0,'r');
draw_camera_pyramid( final_params, tscale, tscale, 2*tscale )

axis equal
grid on
axis auto

