% 
% FIXED_D = 1;
% 
% %% Set up initial parameters
% MODE_ALL_PARAM = 1; % Use all regions' estimated params as hypotheses
% MODE_CLUSTER_K = 2; % Throw all into kmeans and cluster for 2 of them
% MODE_CLUSTER_G = 3; % Use gmeans to more intelligently cluster
% 
% WINDOW_SIZE = 50;
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
% params = multiplane_params_example(10,30);
% 
% if exist('wavefront_fn','var')
%     % multiplane_sim_data;
%     % If want ot use wavefront file, use '/home/ian/PhD/equal-plane-sizes.obj'
%     [planes, trajectory_struct, params, plane_params] = multiplane_read_wavefront_obj( wavefront_fn, params,1 );
% else
%     planes = multiplane_random_plane_generator( 5 );
%     [planes, trajectory_struct, params, plane_params] = multiplane_process_world_planes( planes, params );    
% end
% camTraj = trajectory_struct.camera;
% imTraj = trajectory_struct.image;
% 
% drawPlanes(planes,'world',1,pcolours);
% drawtraj(trajectory_struct.world,'',0,'k');
% 
% allPoints = [imTraj{:}];
% 
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
% % Output estimation details.
% % [plane_ids,confidence] = multiplane_planeids_from_traj( planes, tmpTraj );
% disp('GROUND TRUTH');
% for p=1:length(planes)
%     ground_truth(p,:) = anglesFromN(planeFromPoints(planes(p).camera),1,'degrees');
% end
% disp(ground_truth)
% 
% MAX_ITERATIONS = 3;
% pcolours = ['k','r','b','g','m','c','y'];

%% Find the estimated plane boundaries
for iteration=1:MAX_ITERATIONS
    % Generate hypotheses for each region using the combined solver
    if iteration == 1
        ML = 2;
        STEP = 10;
    else
        ML = 3;
        STEP = 5;
    end
    
    [ output_params, E_thetas, E_psis, E_focals ] = multiplane_combined_solver( restimate(iteration).regions,abs(mm(1,1)-mm(1,2)),ML,STEP );

    restimate(iteration).solver.output_params = output_params;
    restimate(iteration).solver.E_thetas = E_thetas;
    restimate(iteration).solver.E_psis = E_psis;
    restimate(iteration).solver.E_focals = E_focals;
    
    
    
    if iteration > 1
        MODE = MODE_ALL_PARAM;
    end
    
    % Cluster these into a number of known planes
    if MODE == MODE_CLUSTER_K 
        try % If we have 2 planes with same orientation, K-Means gets empty clusters, try reducing K by one.
            [~,hypotheses] = kmeans(output_params,length(planes),'EmptyAction','drop');
        catch err
            [~,hypotheses] = kmeans(output_params,length(planes)-1,'EmptyAction','drop');
        end
    elseif MODE == MODE_CLUSTER_G
        hypotheses = gmeans(output_params,0.001,'pca','ad');
    else
        hypotheses = output_params;
    end
    hypotheses(any(isnan(hypotheses')),:) = []; % Remove dropped clusters
    hypotheses
    restimate(iteration).hypotheses = hypotheses;
    
    % Use the 1px sliding window regions 1 to generate the error matrix for this iteration
   labelCost = multiplane_calculate_label_cost( pixel_regions, hypotheses );
    restimate(iteration).labelCost = labelCost;
    [~,labelling_prealpha] = min(labelCost);
% 
%     if iteration == 1
%         fig_prealpha = figure;
%         pcolours = ['k','r','b','g','m','c','y'];
%         for i=1:length(planes)
%             drawPlane(planes(i).image, '' ,0, pcolours(i));
%         end
%         drawtraj(imTraj,'',0);
%         [~,restimate(iteration).regions] = multiplane_overlay_sliding_regions( restimate(iteration).regions, labelling_prealpha);
%     
%         saveas(fig_prealpha,sprintf('regions_iteration-%d.fig',iteration));
%     end

    [boundary_pts,errthresh] = find_boundaries_from_error( pixel_regions, planes, min(restimate(iteration).labelCost), 2 );
    [region_trajectories, plane_regions, plane_graph] = multiplane_boundary_trajectory_split( trajectory_struct.image, boundary_pts );


    drawPlanes(plane_regions,'image',1,pcolours)

    gtcolours = repmat(['m','c','y','g'],1,6);
    drawPlanes(planes,'image',0,gtcolours)

    % Create regions for next iteration
    for r=1:length(plane_regions)
        drawtraj(region_trajectories{r},'',0,pcolours(r));
        restimate(iteration+1).regions(r).traj = region_trajectories{r};
    end
    
    restimate(iteration+1).plane_graph = plane_graph;

    empties = arrayfun(@(x) isempty(x.traj), restimate(iteration+1).regions);
    regions = arrayfun( @addemptyfield, restimate(iteration+1).regions, empties);
end

% work out which hypotheses best fit which region
relabel_cost = multiplane_calculate_label_cost( regions, hypotheses );
[~,hypothesis_assignment] = min(relabel_cost);
hypotheses = hypotheses(hypothesis_assignment,:);
save iterative_boundary_estimation_data

root_hypothesis = hypotheses(1,:);


% get initial condition from angles betweeen existing planes.
init_angles = hinged_initial_condition( hypotheses);

% use fsolve on hinged error func
fsolve_options;
options = optimset('TolFun',1e-4);
[output_angles,fval,exitflag,output] = fsolve(@(x) hinged_errorfunc( regions,plane_graph,boundary_pts,x,root_hypothesis),init_angles,options);

regions = hinged_reconstruction( root_hypothesis, output_angles, boundary_pts, plane_graph, regions );

figure;
pcolours = ['k','r','b','g','m','c','y'];
for r=1:length(regions)
    rPts = [regions(r).reconstructed{:}];
    hIdx = convhull(rPts(1,:),rPts(2,:),rPts(3,:));
    
    size(rPts(hIdx(:,1)))
    size(rPts(hIdx(:,2)))
    size(rPts(hIdx(:,3)))
%     scatter3(rPts(1,:),rPts(2,:),rPts(3,:), 24, strcat('*',pcolours(r)))
    hold on
%     pause
    [rotmat,cornerpoints]  = minboundbox(rPts(1,:), rPts(2,:),rPts(3,:),'v',1);
    plotminbox(cornerpoints,pcolours(r));
end

return


