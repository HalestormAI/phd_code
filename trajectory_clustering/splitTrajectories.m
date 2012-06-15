function [splitTraj,stats] = splitTrajectories( traj, drawfigs )

    if nargin < 2
        drawfigs = 0;
    end

    if iscell(traj)
        
        % Clear empty trajectories and those under length 2
        splitTraj = cellfun(@splitTrajectories, traj, 'uniformoutput', false);
        splitTraj = vertcat(splitTraj{:});
    else

        lengths = traj_speeds(traj);
        % Find mean & std
        mL = mean(lengths);
        sL = std(lengths);
        stats = [mL,sL];
        
        % Find ids where -3*std < length < 3*std
        gt = find( lengths > mL+2*sL );
        lt = find( lengths < mL-2*sL );
        
        
        bad = (unique(union(gt,lt)))+1;
        
        % Doesn't need splitting, save some time!
        if isempty(bad)
            splitTraj = traj;
        else
            good = 1:length(traj);
            good(bad) = [];
            % Split
            splitTrajIds = SplitVec(good,'consecutive')';
            tLengths = cellfun(@length,splitTrajIds);
            splitTrajIds(tLengths <= 1) = [];
            splitTraj = cellfun(@(x) traj(:,x),splitTrajIds,'uniformoutput',false);
        end
        if drawfigs

            f2 = figure;
            subplot(2,2,[3,4]);

            bar(lengths);
            hold on;
            ax = axis;
            plot(ax(1:2),[mL,mL],'m-');
            plot(ax(1:2),[mL+3*sL,mL+3*sL],'g-');
            plot(ax(1:2),[mL-3*sL,mL-3*sL],'g-');
            title('Length distribution showing mean and acceptable range (3 Std Devs)');
            
            subplot(2,2,1);
            drawtraj(traj,'',0);
            axis equal;
            subplot(2,2,2);

            colours = ['r','b','g','m','y'];

            for i=1:length(splitTraj)
                drawtraj(splitTraj{i},'',0,colours(i));
            end
            axis equal;
            suptitle('Trajectory split based on imaged speed');
            
            saveas(f2, sprintf('split_%d.fig',drawfigs));
        end
    end
    
    
end

    