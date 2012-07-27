NUM_ITERATIONS = 3;

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
% % multiplane_sim_data;
% mm = minmax([imTraj{:}]);
% regions = multiplane_gen_sliding_regions(mm, 250, imTraj, 75);
% 
% output_params = cell(length(regions),1);
% finalError    = cell(length(regions),1);
% fullErrors    = cell(length(regions),1);
% inits         = cell(length(regions),1);
% % 
% % % Use only one trajectory
% % for t=1:length(tmpTraj)
% %     plane_details.trajectories = traj2imc(tmpTraj(t),1,1);
% %     
% %     % NEED TO MODIFY multiscaleSolver so that it looks at more than one position.
% %     [ output_params{t}, finalError{t}, fullErrors{t}, inits{t} ] = multiplane_multiscaleSolver( 1, plane_details, 3, 10, 1e-12 );
% % end
% 

% [output_mat(plane_ids==1,1:2)]'
% [output_mat(plane_ids==2,1:2)]'

% regions = multiplane_generate_regions( tmpTraj );

%% Now assign each trajectory a plane

labelling = cell(NUM_ITERATIONS,1);
old_regions = cell(NUM_ITERATIONS,1);

for iteration = 1: NUM_ITERATIONS
    
    %% Region based Estimation
    output_params = cell(length(regions),1);
    finalError    = cell(length(regions),1);
    fullErrors    = cell(length(regions),1);
    inits         = cell(length(regions),1);
    for r=1:length(regions)
    %     plane_details.trajectories = traj2imc(multiplane_trajectories_for_region( tmpTraj, regions(r) ),1,1);
        fprintf('Region: %d\n',r);
        if length(regions(r).traj) < 1
            fprintf('\tNo trajectories in region\n');
            continue;
        end
        plane_details.trajectories = traj2imc( regions(r).traj,1,1 );
        [ output_params{r}, finalError{r}, fullErrors{r}, inits{r} ] = multiplane_multiscaleSolver( 1, plane_details, 3, 10, 1e-12 );
    end

    disp('ESTIMATES');
    output_mat = cell2mat(output_params)

    % Output estimation details.
    % [plane_ids,confidence] = multiplane_planeids_from_traj( planes, tmpTraj );
    disp('GROUND TRUTH');
    anglesFromN(planeFromPoints(planes(1).camera),1,'degrees')
    anglesFromN(planeFromPoints(planes(2).camera),1,'degrees')
    
    % Collect all regions' subtrajectories into big array
    regionTraj = {regions.traj}';
    subtraj = vertcat(regionTraj{:});
    subc = traj2imc(subtraj,1,1);
    subtraj(cellfun(@length,subc)<4) = [];
    subc(cellfun(@length,subc)<4) = [];
    
    
    % preprocess step - convert all angles from outputmat to normals
    normals = zeros(3,size(output_mat,1));
    for o = 1:size(output_mat)
        normals(:,o) = normalFromAngle(output_mat(o,1),output_mat(o,2),'degrees');
    end
    
    % ... build  matrix of cost for subtrajectory against plane estimate
    labelCost = NaN.*ones(size(output_mat,1),length(subc));
    smoothCost = zeros(size(output_mat,1));
    for e=1:size(output_mat,1)
        for t=1:length(subc)
            labelCost(e,t) = errorfunc( output_mat(e,1:2), [1,output_mat(e,3)], subc(t));
        end
        
        % Build smooth cost: angle between planes.
        for f=e:size(output_mat,1)
            n1 = normals(:,e);
            n2 = normals(:,f);
            smoothCost(e,f) = real(acos(dot(n1,n2) / (norm(n1)*norm(n2))));
            smoothCost(f,e) = smoothCost(e,f);
        end
    end

%     IM1 = mat2gray(labelCost);
%     figure;imagesc(IM1)
%     axis equal;
%     axis([1 length(subc) 1 length(output_mat)]);
%     xlabel('Plane Hypothesis');
%     ylabel('Sub-Trajectory ID');
%     title('Heatmap of plane hypothesis error');
%     
%     IM2 = mat2gray(smoothCost');
%     figure;imagesc(IM2)
%     axis equal;
%     axis([1 size(smoothCost,2) 1 size(smoothCost,1)]);
%     xlabel('Plane Hypothesis');
%     ylabel('Plane Hypothesis');
%     title('Heatmap of smoothness cost between hypotheses');
%     
    
    % ... build matrix of image distance for each trajectory
    assignment =  cell(length(subtraj),length(subtraj));
    distanceCost = zeros(length(subtraj),length(subtraj));
    for i=1:length(subtraj)
        for j=i:length(subtraj)
            if i==j
                distanceCost(i,j) = NaN; %Can't match to itself
            else
                input_cost = cluster_traj( subtraj{i},subtraj{j} );
                [assignment{i,j},distanceCost(i,j)] = assignmentoptimal( input_cost );
            end
            distanceCost(j,i) = distanceCost(i,j);
        end
        fprintf('\tRow %d of %d done.\n', i, length(subtraj));
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
    SMOOTHCOEFF    = 1;
    NEIGHBOURCOEFF = 100;
    LABELCOEFF     = 100;
    
    alphaObj = GCO_Create(length(subtraj),size(output_mat,1));
    GCO_SetDataCost( alphaObj, LABELCOEFF.*labelCost );
    GCO_SetSmoothCost( alphaObj, SMOOTHCOEFF.*smoothCost );
    GCO_SetNeighbors( alphaObj, NEIGHBOURCOEFF .* distanceCost );
    GCO_Expansion(alphaObj);
    labelling{iteration} = GCO_GetLabeling(alphaObj);

    labels = unique(labelling{iteration});

    % Get the planes for each label
    planeids = NaN.*ones(length(labels),1);
    for l=1:length(labels)
        ids = multiplane_planeids_from_traj( planes, subtraj(labelling{iteration} == labels(l)) );
        planeids(l) = mean(ids);
    end
    
    old_regions{iteration} = regions;
    clear regions;
    
    % Get new regions as labelled trajectory segments
    for l=1:length(labels)
        regions(l).traj = subtraj(labelling{iteration} == labels(l));
    end
end