function [cluster_struct,assignment,outputcost,imtraj,trajectory_distances,trajectory_shapes] = traj_cluster_munkres( trajectories, FPS, NUM_LONGEST, draw, cost_weighting, MAX_DISTANCE) 


    if nargin < 4 || isempty(draw)
        draw = 0;
    end

    if nargin < 3
        NUM_LONGEST = 20;
    end

    
    NUM_LONGEST = min(length(trajectories), NUM_LONGEST);
    
    lengths = cellfun(@length, trajectories);
    [~,sortedIds] = sort(lengths,'descend');
    longestIds = sortedIds(1:NUM_LONGEST);
    
    imtraj = traj2imc(trajectories(longestIds),FPS,1);
    %     drawcoords( imtraj,'',0,'k' );

%     imtraj = cellfun(@(x) x(:,1:FPS:end), imtraj, 'un',0);
    

    
    
    if nargin < 6
        rng = range(horzcat(imtraj{:}),2);
        MAX_DISTANCE = rng(1)*0.1;
    end

    disp('Calculating assignment errors');
    assignment =  cell(length(imtraj),length(imtraj));
    outputcost = zeros(length(imtraj),length(imtraj));
%     distance_cost = cell(length(imtraj),length(imtraj));
    shape_cost = cell(length(imtraj),length(imtraj));
    trajectory_distances = zeros(length(imtraj),length(imtraj));
    trajectory_shapes = zeros(length(imtraj),length(imtraj));
    
    if nargin < 5
        cost_weighting = [ 0.5 0.5 ];
    end
    
    for i=1:length(imtraj)
        imtraj_i = imtraj{i};
        for j=i:length(imtraj)
            % Get point-point similarities for trajectories
            [input_cost,distance_cost] = cluster_traj( imtraj_i,imtraj{j}, cost_weighting );
% input_cost = cluster_traj( imtraj_i,imtraj{j}, cost_weighting );
% 
            
            % Align trajectories in optimal way, get alignment cost
            [assignment{i,j},outputcost(i,j)] = assignmentoptimal( input_cost ); 
            
            %TODO: Need to find a way to get a distance measure out for an
            %assignment, then threshold before throwing at
            %adapt_apcluster.m (affinity propagation)
            trajectory_distances(i,j) = assigment_distance( assignment{i,j}, distance_cost );
%             trajectory_shapes(i,j) = assigment_shape( assignment{i,j}, shape_cost{i,j} );
        end
        fprintf('\tRow %d of %d done.\n', i, length(imtraj));
    end

    disp('Calculating Matches');
    
    %  Convert output_cost to affinity
    affinity = max(max(outputcost))-outputcost;
    
    % Force no affinity if too far away (e.g. 10% of image width)
    unacceptible = logical(trajectory_distances > MAX_DISTANCE);
    affinity(unacceptible) = 0;
    
    for i=1:length(imtraj)
        for j=1:length(imtraj)
            affinity(j,i) = affinity(i,j);
        end
    end
    
    % Cluster using affinity propagation
    cluster_index = apcluster(affinity,median(affinity));
    
    indices = unique(cluster_index);
   
    
    cluster_struct.colours          = colourForLabels( 1:length(indices) );
    cluster_struct.labels           = indices;
    cluster_struct.labelling        = cluster_index;
    cluster_struct.representative   = find_representative( cluster_struct, outputcost, imtraj, draw );
    cluster_struct.chosen_ids       = longestIds;

    function mean_shape = assigment_shape( ass , shapes )
        subs = [1:length(ass);ass']'; % Get the subscript indices
        subs(~subs(:,2),:) = []; % remove all where a vertex doesn't match
        idx = sub2ind(size(shapes), subs(subs(:,2)>0,1), subs(subs(:,2)>0,2));
        mean_shape = mean(shapes(idx));
    end
end

%  medianTraj = medianAssignment(fpstraj, matches, assignment);
% 
% figure;
% subplot(1,2,1);
% image(frame);
% colours = ['r','b','g','m','y'];
% for i=1:length(matches)
%     drawtraj(imtraj(matches{i}),'',0,colours(i),4,'-');
% end
% drawtraj(imtraj,'',0,'k',[],'-');
% title('Trajectory Group Assignments');
% 
% subplot(1,2,2);
% image(frame);
% drawtraj(imtraj,'',0,'k',2,'-');
% for i=1:length(matches)
%     drawtraj(medianTraj{i},'',0,colours(i),2,'-');
% end
% title('Median Trajectory Clusters');