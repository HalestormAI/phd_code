function [clusters,matches,assignment,outputcost] = traj_cluster_munkres( trajectories, FPS, NUM_LONGEST, draw )

    if nargin < 3
        NUM_LONGEST = 20;
    end

    lengths = cellfun(@length, trajectories);
    [~,sortedIds] = sort(lengths,'descend');
    longestIds = sortedIds(1:NUM_LONGEST);
    imtraj = traj2imc(trajectories(longestIds),FPS,1);
%     drawcoords( imtraj,'',0,'k' );

%     imtraj = cellfun(@(x) x(:,1:FPS:end), imtraj, 'un',0);
    
    disp('Calculating assignment errors');
    assignment =  cell(length(imtraj),length(imtraj));
    outputcost = zeros(length(imtraj),length(imtraj));
    for i=1:length(imtraj)
        for j=i:length(imtraj)
            input_cost = cluster_traj( imtraj{i},imtraj{j} );
%             fprintf('Done building error matrix (%d,%d). ',i,j);
            [assignment{i,j},outputcost(i,j)] = assignmentoptimal( input_cost );
            outputcost(j,i) = outputcost(i,j);
%             fprintf('Element (%d,%d) of (%d,%d)\n',i,j,length(imtraj),length(imtraj));
        end
        fprintf('\tRow %d of %d done.\n', i, length(imtraj));
    end
    
    meanerror = mean(nanmean(outputcost));
    stderror = std(nanstd(outputcost));

    errTol = meanerror-3*stderror;

    matches = {};

    disp('Calculating Matches');
%     
%     [~,minidx] = min(outputcost);
%     matches = findMatches(minidx);
    
    for i=1:length(imtraj)
        m = outputcost(i,:) < errTol;
        for j=(i+1):length(imtraj)
    %         Is i in matches?
            if m(j)
                idx = find(cellfun(@(x) logical(numel(find(x==i))),matches));
                if isempty(idx)
                   matches{end+1} = [i,j];
                else
                    if numel(idx) > 1
                      costs = outputcost(i,idx);
                      [~,idx] = min(costs);
                    end
                    if isempty(find(matches{idx}==j,1,'first'))
                        matches{idx}(end+1) = j;
                    end
                end
            end
        end
    end
    
    % Find any trajectories that haven't been clustered
    groupIds = inMatches( 1:length(imtraj), matches);
    
    notClustered = find(~groupIds);
    for n=1:length(notClustered)
        matches{end+1} = notClustered(n);
    end
    
    
    clusters = longestAssignment( imtraj, matches );
%     return;


    disp('Drawing');
    if length(clusters) > 7
        disp('Too many clusters to draw');
        length(clusters);
        return
    end
    if nargin >= 4 && (numel(draw) > 1 || draw)
        figure;
%         subplot(1,2,1);
        image(draw);
        colours = ['r','b','g','m','y','w','c'];
        disp('Drawing matched traj');
        for i=1:length(matches)
            drawtraj(imtraj(matches{i}),'',0,colours(i),4,'-');
        end
        disp('drawing original traj');
        drawtraj(imtraj,'',0,'k',[],'-');
        title('Trajectory Group Assignments');
        
%         subplot(1,2,2);
%         image(draw);
%         drawtraj(imtraj,'',0,'k',2,'-');
%         for i=1:length(matches)
%             drawtraj(clusters{i},'',0,colours(i),2,'-');
%         end
%         title('Median Trajectory Clusters');
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