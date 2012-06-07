function [splitTraj,stats] = splitTrajectories( traj )

    if iscell(traj)
        splitTraj = cellfun(@splitTrajectories, traj, 'uniformoutput', false);
        splitTraj = vertcat(splitTraj{:});
    else
        lengths = vector_dist(traj);
        % Find mean & std
        mL = mean(lengths);
        sL = std(lengths);
        
        % Find ids where -3*std < length < 3*std
        gt = find( lengths > mL+3*sL );
        lt = find( lengths > mL+3*sL );
        
        
        
        bad = mpid2cid(unique(union(gt,lt)));
        good = 1:length(traj);
        good(bad) = [];
        % Split
        splitTrajIds = SplitVec(good,'consecutive')';
        tLengths = cellfun(@length,splitTrajIds);
        splitTrajIds(tLengths <= 1) = [];
        splitTraj = cellfun(@(x) traj(:,x),splitTrajIds,'uniformoutput',false);
        
        stats = [mL,sL];
    end
end

    