SMOOTHCOEFF    = 1;
% NEIGHBOURCOEFF = 100;
% LABELCOEFF     = 100;
% NUM_ITERATIONS = 1;
% 
% MODE_ALL_PARAM = 1; % Use all regions' estimated params as hypotheses
% MODE_CLUSTER_2 = 2; % Throw all into kmeans and cluster for 2 of them
% 
% WINDOW_SIZE = 100;
% WINDOW_DISTANCE = 75;
% 
% 
% 
% MODE = MODE_CLUSTER_2;
% 
% multiplane_sim_data;
% 
% % now split all trajectories more than length 10 in half
% tmpTraj = cell(2*length(imTraj),1);
% 
% trajLengths = cellfun(@length,tmpTraj);
% 
% num = 1;
% for i=1:length(imTraj)
%     t = imTraj{i};
%     if(length(t) >= mean(trajLengths))
%         tmpTraj{num} = t(:,1:ceil(length(t)/2));
%         tmpTraj{num+1} = t(:,ceil(length(t)/2):end);
%         num = num + 2;
%     else
%         tmpTraj{num} = t;
%         num = num + 1;
%     end
% end
% 
% tmpTraj(num:end) = [];
% 
% 
% multiplane_sim_data;
% mm = minmax([imTraj{:}]);
% regions = multiplane_gen_sliding_regions(mm, WINDOW_SIZE, imTraj, WINDOW_DISTANCE);

%% Now assign each trajectory a plane

labelling = cell(NUM_ITERATIONS,1);

for iteration = 1: NUM_ITERATIONS
%     
%     %% Region based Estimation
%     output_params = cell(length(regions),1);
%     finalError    = cell(length(regions),1);
%     fullErrors    = cell(length(regions),1);
%     inits         = cell(length(regions),1);
%     for r=1:length(regions)
%     %     plane_details.trajectories = traj2imc(multiplane_trajectories_for_region( tmpTraj, regions(r) ),1,1);
%         fprintf('Region: %d\n',r);
%         if length(regions(r).traj) < 1
%             regions(r).empty = 1;
%             fprintf('\tNo trajectories in region\n');
%             continue;
%         end
%         regions(r).empty = 0;
%         plane_details(r).trajectories = traj2imc( regions(r).traj,1,1 );
%         [ output_params{r}, finalError{r}, fullErrors{r}, inits{r} ] = multiplane_multiscaleSolver( 1, plane_details(r), 3, 10, 1e-12 );
%     end
% 
%     disp('ESTIMATES');
%     output_mat = cell2mat(output_params);
%     
%     if MODE == MODE_CLUSTER_2
%         [~,hypotheses] = kmeans(output_mat,2);
%     else
%         hypotheses = output_mat;
%     end

    % Output estimation details.
    % [plane_ids,confidence] = multiplane_planeids_from_traj( planes, tmpTraj );
%     disp('GROUND TRUTH');
%     anglesFromN(planeFromPoints(planes(1).camera),1,'degrees')
%     anglesFromN(planeFromPoints(planes(2).camera),1,'degrees')
%     
    % Collect all regions' subtrajectories into big array
    regionTraj = {regions.traj}';
    subtraj = vertcat(regionTraj{:});
    
    
    % preprocess step - convert all angles from outputmat to normals
    normals = zeros(3,size(hypotheses,1));
    for o = 1:size(hypotheses)
        normals(:,o) = normalFromAngle(hypotheses(o,1),hypotheses(o,2),'degrees');
    end
    
    % ... build  matrix of cost for region against plane estimate
    labelCost = NaN.*ones(size(hypotheses,1),length(regions));
    smoothCost = zeros(size(hypotheses,1));
    for e=1:size(hypotheses,1)
        for r=1:length(regions)
%             if regions(r).empty
%                 labelCost(e,r) = Inf;
%             else
                labelCost(e,r) = sum(errorfunc( hypotheses(e,1:2), [1,hypotheses(e,3)], traj2imc(regions(r).traj,1,1)).^2);
%             end
        end
        
        % Build smooth cost: angle between planes.
        for f=e:size(hypotheses,1)
            n1 = normals(:,e);
            n2 = normals(:,f);
            smoothCost(e,f) = real(acos(dot(n1,n2) / (norm(n1)*norm(n2))));
            smoothCost(f,e) = smoothCost(e,f);
        end
    end
    
    % ... build matrix of image distance for each trajectory
    distanceCost = zeros(length(regions));
    for r1=1:length(regions)
        for r2=r1:length(regions)
            if r1==r2
                distanceCost(r1,r2) = NaN; %Can't match to itself
            else
                distanceCost(r1,r2) = vector_dist(regions(r1).centre, regions(r2).centre);
            end
            distanceCost(r2,r1) = distanceCost(r1,r2);
        end
        fprintf('\tRow %d of %d done.\n', r1, length(regions));
    end
    
    % normalise and convert cost to affinity
    distanceCost = 1 - distanceCost ./ max(max(distanceCost)); 
    distanceCost(isnan(distanceCost)) = 0;
%     
%     IM3 = mat2gray(distanceCost');
%     figure;imagesc(IM3)
%     axis equal;
%     axis([1 size(distanceCost,2) 1 size(distanceCost,1)]);
%     xlabel('Trajectory ID');
%     ylabel('Trajectory ID');
%     title('Heatmap of image distance affinities between trajectories (red is better)');
%     
    
    alphaObj = GCO_Create(length(regions),size(hypotheses,1));
    GCO_SetDataCost( alphaObj, LABELCOEFF.*labelCost );
    GCO_SetSmoothCost( alphaObj, SMOOTHCOEFF.*smoothCost );
    GCO_SetNeighbors( alphaObj, NEIGHBOURCOEFF .* distanceCost );
    GCO_Expansion(alphaObj);
    labelling{iteration} = GCO_GetLabeling(alphaObj);

    labels = unique(labelling{iteration});
    
    labelling{iteration}(logical([regions.empty])) = 0;

    % Get the planes for each label
    planeids = NaN.*ones(length(labels),1);
    for l=1:length(labels)
        ids{l} = multiplane_planeids_from_traj( planes, subtraj(labelling{iteration} == labels(l)) );
        planeids(l) = mean(ids{l});
    end
    
    history(iteration).smoothCost   = smoothCost;
    history(iteration).distanceCost = distanceCost;
    history(iteration).labelCost    = labelCost;
    history(iteration).labelling    = labelling;
    history(iteration).regions      = regions;
    clear regions;
    
    % TODO: Get new trajectory segments for new regions.
    for l=1:length(labels)
        regions(l).traj = subtraj(labelling{iteration} == labels(l));
        regions(l).centre = mean([regions(l).traj{:}],2);
    end
end