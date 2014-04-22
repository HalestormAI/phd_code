% % % FIXED_D = 1;
% % %
% % % %% Set up initial parameters
% % % MODE_ALL_PARAM = 1; % Use all regions' estimated params as hypotheses
% % % MODE_CLUSTER_K = 2; % Throw all into kmeans and cluster for 2 of them
% % % MODE_CLUSTER_G = 3; % Use gmeans to more intelligently cluster
% % %
% % % WINDOW_SIZE = 25;
% % % WINDOW_DISTANCE = WINDOW_SIZE/2;
% % %
% % % pcolours = repmat(['k','r','b','g','m','c','y'],1,6);
% % %
% % % rootFld = sprintf('hinged-%s-winsz_%d-windist_%d',datestr(now,'HH-MM-SS'), WINDOW_SIZE, WINDOW_DISTANCE);
% % % mkdir(rootFld);
% % % pushd( rootFld );
% % %
% % % MODE = MODE_CLUSTER_K;
% % %
% % % params = multiplane_params_example(10,30,[],[], NOISE_LEVEL);
% % %
% % % if exist('wavefront_fn','var')
% % %     % multiplane_sim_data;
% % %     % If want ot use wavefront file, use '/home/ian/PhD/equal-plane-sizes.obj'
% % %     [planes, trajectory_struct, params, plane_params] = multiplane_read_wavefront_obj( wavefront_fn, params,1 );
% % % else
% % %     planes = multiplane_random_plane_generator( 2, [41]);
% % %
% % %     [planes, trajectory_struct, params, plane_params] = multiplane_process_world_planes( planes, params );
% % % end
% % % camTraj = trajectory_struct.camera;
% % % imTraj = trajectory_struct.image;
% % % save input_data;
% % % figure;
% % % subplot(1,2,1)
% % % drawPlanes(planes,'world',0,pcolours);
% % % drawtraj(trajectory_struct.world,'',0,'k');
% % % subplot(1,2,2);
% % % drawPlanes(planes,'image',0,pcolours);
% % % drawtraj(trajectory_struct.image,'',0,'k');
% % % allPoints = [imTraj{:}];
% % % % pause
% % % %% Generate Initial Regions
% % % mm = minmax([imTraj{:}]);
% % % regions = multiplane_gen_sliding_regions(mm, WINDOW_SIZE, imTraj, WINDOW_DISTANCE);
% % % % abs(mm(1,1)-mm(1,2))
% % %
% % % empties = arrayfun(@(x) isempty(x.traj), regions);
% % % regions = arrayfun( @addemptyfield, regions, empties);
% % %
% % %
% % % history(1).regions = regions;
% % % pixel_regions = multiplane_gen_sliding_regions(mm, WINDOW_SIZE, imTraj, 2);
% % % pempties = arrayfun(@(x) isempty(x.traj), pixel_regions);
% % % pixel_regions = arrayfun( @addemptyfield, pixel_regions, pempties);
% % %
% % %
% % % region_dims = ceil(range(ceil(mm'))./2);
% % % % Output estimation details.
% % % % [plane_ids,confidence] = multiplane_planeids_from_traj( planes, tmpTraj );
% % % disp('GROUND TRUTH');
% % % for p=1:length(planes)
% % %     ground_truth(p,:) = anglesFromN(planeFromPoints(planes(p).camera),1,'degrees');
% % % end
% % % disp(ground_truth)
% % %
% MAX_ITERATIONS = 3;
% % % pcolours = ['k','r','b','g','m','c','y'];
% % %
% % % BOUNDARY_METHOD = 'SVM';
% % %
% % % save input_data;
% %
% %% Find the estimated plane boundaries
% for iteration=3:MAX_ITERATIONS
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
%         [ output_mat, E_thetas, E_psis, E_focals ] = multiplane_combined_solver( history(iteration).regions,abs(mm(1,1)-mm(1,2)),ML,STEP );
%         
%         history(iteration).solver.output_mat = output_mat;
%         history(iteration).solver.E_thetas = E_thetas;
%         history(iteration).solver.E_psis = E_psis;
%         history(iteration).solver.E_focals = E_focals;
%         
%         if iteration == 1
%             output_mat = multiplane_filter_output_params( output_mat );
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
%                     [~,hypotheses] = kmeans(output_mat,length(planes));
%                     break;
%                 catch err
%                     disp('empty cluster, trying again');
%                 end
%             end
%         elseif MODE == MODE_CLUSTER_G
%             hypotheses = gmeans(output_mat,0.001,'pca','ad');
%         else
%             hypotheses = output_mat;
%         end
%         hypotheses(any(isnan(hypotheses')),:) = []; % Remove dropped clusters
%         hypotheses
%         history(iteration).hypotheses = hypotheses;
%         
%         % Use the 1px sliding window regions 1 to generate the error matrix for this iteration
%         labelCost = multiplane_calculate_label_cost( pixel_regions, hypotheses );
%         history(iteration).labelCost = labelCost;
%         
%         [mincosts,labelling_prealpha] = min(labelCost);
%     end
%     try
%         svm_line_splitter;
%         boundary_pts{1} = linePoints';
%     catch err
%         angles = 0:180;
%         clear lcentres
%         lcentres(1,:) = mm(1,1):5:mm(1,2);
%         lcentres(2,:) = repmat(mean(mm(2,:)),1,length(lcentres(1,:)));
%         
%         lcentres = lcentres(:,5:(end-5));
%         
%         [bl_errors_1, bl_errors_2] = multiplane_script_plane_dividing_line( imTraj, hypotheses, lcentres, angles );
%         likelihood = repmat(gausswin(length(lcentres)),1,length(angles));
%         filtered_errors_1 = nanmean(bl_errors_1(bl_errors_1~=Inf)-2*nanstd(bl_errors_1(bl_errors_1~=Inf)))*(1-likelihood)+bl_errors_1;
%         filtered_errors_2 = nanmean(bl_errors_1(bl_errors_2~=Inf)-2*nanstd(bl_errors_1(bl_errors_2~=Inf)))*(1-likelihood)+bl_errors_2;
%         
%         bl_minE1 = min(min(filtered_errors_1));
%         bl_minE2 = min(min(filtered_errors_2));
%         
%         if sum(bl_errors_1(bl_errors_1~=Inf)) < sum(bl_errors_2(bl_errors_2~=Inf))
%             [row,col] = find(filtered_errors_1 == bl_minE1,1,'first')
%         else
%             [row,col] = find(filtered_errors_2 == bl_minE2,1,'first')
%         end
%         
%         centre(:,iteration) = lcentres(:, row);
%         angle(iteration) =  angles(col);
%         [sideTrajectories, trajIds,boundary_pts{1}] = multiplane_split_trajectories_for_line( imTraj, centre(:,iteration), angle(iteration),0);
%         
%         
%         
%         history(iteration).output_mat   = output_mat;
%         % history(iteration).fullErrors   = fullErrors;
%         history(iteration).centre       = centre;
%         history(iteration).angle        = angle;
%         history(iteration).regions      = regions;
%         
%         %         region_intersect = minmax(linePoints');
%         
%         clear regions;
%         for r=1:2
%             regions(r).traj = sideTrajectories{r};
%             regions(r).centre = mean(minmax([sideTrajectories{r}{:}]),2);
%             regions(r).radius = max(range([sideTrajectories{1}{:}],2));
%             regions(r).empty = 0;
%         end
%         
%         history(iteration+1).regions = regions;
%         
%     end
% end
% plane_graph = [0 1];
% 
% % work out which hypotheses best fit which region
% relabel_cost = multiplane_calculate_label_cost( regions, hypotheses );
% [~,hypothesis_assignment] = min(relabel_cost);
% hypotheses = hypotheses(hypothesis_assignment,:);
% save iterative_boundary_estimation_data

root_hypothesis = hypotheses(1,:);


% get initial condition from angles betweeen existing planes.
init_angles = hinged_initial_condition( hypotheses);
% init_angles = [31 20]
% use fsolve on hinged error func
fsolve_options;
options = optimset('TolFun',1e-4);


regions,plane_graph,boundary_pts,root_hypothesis
[output_angles,fval,exitflag,output] = fsolve(@(x) hinged_errorfunc( regions,plane_graph,boundary_pts,x,root_hypothesis),init_angles,options);
output_angles

regions = hinged_reconstruction( root_hypothesis, init_angles, boundary_pts, plane_graph, regions );

alltrajest = [regions.reconstructed];

meanlengths_est = cellfun(@(x) mean(vector_dist(traj2imc(x,1,1))), alltrajest);
meanlengths_gt = cellfun(@(x) mean(vector_dist(traj2imc(x,1,1))), trajectory_struct.camera);
tscale = mean(meanlengths_est) / mean(meanlengths_gt);


figure;
pcolours = ['b','r'];
for r=1:length(regions)
    rPts = [regions(r).reconstructed{:}];
    hIdx = convhull(rPts(1,:),rPts(2,:),rPts(3,:));
    
    %     scatter3(rPts(1,:),rPts(2,:),rPts(3,:), 24, strcat('*',pcolours(r)))
    hold on
    %     pause
    [rotmat,cornerpoints]  = minboundbox(rPts(1,:), rPts(2,:),rPts(3,:),'v',1);
     plotminbox(cornerpoints./tscale - repmat(ttrans',size(cornerpoints,1),1),pcolours(r));
    drawtraj(cellfun(@(x) (x./tscale) - repmat(ttrans,1,size(x,2)),regions(r).reconstructed,'un',0),'',0,pcolours(r))
end


final_params = params;
focal_point = mean([alltrajest{:}],2);
final_params.camera.rotation= -params.camera.rotation;
final_params.camera.height=vector_dist([0;0;0],focal_point);
final_params.camera.position = multiplane_camera_position(focal_point, final_params);

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
