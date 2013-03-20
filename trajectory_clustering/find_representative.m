function [representative, ids] = find_representative( cluster_struct, outputcost, imtraj, frame )


    if nargin == 4 && ~isempty(find(frame,1,'first')) && logical(find(frame,1,'first'))
        figure;
        subplot(1,2,1);
        image(frame);
    end
    
    % Copy matrix upper triangle to lower triangle
    output_cost_full = triu(outputcost)+triu(outputcost,1)';
    
    
    representative =  cell(length(cluster_struct.labels),1);
    ids            = zeros(length(cluster_struct.labels),1);
    
    for c=1:length(cluster_struct.labels)
    % Need to assess distance and shape fit
        traj_ids = find(cluster_struct.labelling == cluster_struct.labels(c));

        traj_length = zeros(length(traj_ids),1);
        traj_cost = zeros(length(traj_ids),1);

        for t=1:length(traj_ids)    
            traj_length(t) = length(imtraj{traj_ids(t)});
            traj_cost(t) = sum(output_cost_full(traj_ids(t),traj_ids)) / length(imtraj{traj_ids(t)});
        end

        [~,MINIDX] = min(traj_cost);

        ids(c) = traj_ids(MINIDX);
        representative(c) = imtraj(traj_ids(MINIDX));
        if nargin == 4 && ~isempty(find(frame,1,'first')) && logical(find(frame,1,'first'))
            drawtraj(imtraj(traj_ids(MINIDX)),'',0,'k',10);
            drawtraj(imtraj(traj_ids),'',0,cluster_struct.colours(c,:));
        end

        % IDEA: look at cost of assigning trajectory t to all other
        % trajectories in its cluster (normalise over length).

    end


    if nargin == 4 && ~isempty(find(frame,1,'first')) && logical(find(frame,1,'first'))
        subplot(1,2,2);
        imagesc(frame);
        for c=1:length(cluster_struct.labels)
            drawtraj(representative{c},'',0,cluster_struct.colours(c,:),3);
        end
    end
end