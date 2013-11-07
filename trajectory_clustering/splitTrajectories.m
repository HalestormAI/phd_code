function [splitTraj,stats] = splitTrajectories( traj, drawfigs, THRESH )

    if nargin < 2
        drawfigs = 0;
    end
    
    if nargin < 3
        THRESH = 2;
    end

    if iscell(traj)
        
        % Clear empty trajectories and those under length 2
        splitTraj = cellfun(@(x) splitTrajectories(x,drawfigs), traj, 'uniformoutput', false);
        splitTraj = vertcat(splitTraj{:});
    else

        lengths = traj_speeds(traj);
        % Find mean & std
        mL = mean(lengths);
        sL = std(lengths);
        stats = [mL,sL];
        
        % Find ids where -3*std < length < 3*std
        gt = find( lengths > mL+THRESH*sL );
        lt = find( lengths < mL-THRESH*sL );
        
        bad = (unique_c([gt,lt]))+1;
        
        % Doesn't need splitting, save some time!
        if isempty(bad)
            splitTraj{1} = traj;
        else
            good = 1:length(traj);
            good(bad) = [];
            % Split
            %splitTrajIds = SplitVec(good,'consecutive')';
            [~,splitTrajIds] = split_vector(good);
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
            plot(ax(1:2),[mL+THRESH*sL,mL+THRESH*sL],'g-');
            plot(ax(1:2),[mL-THRESH*sL,mL-THRESH*sL],'g-');
            title(sprintf('Length distribution showing mean and acceptable range (%d Std Devs)',THRESH));
            
            subplot(2,2,1);
            drawtraj(traj,'',0);
            axis equal;
            subplot(2,2,2);

            colours = ['r','b','g','m','c'];

            for i=1:length(splitTraj)
                hold on;
                drawtraj(splitTraj{i},'',0,colours(i));
            end
            axis equal;
            suptitle('Trajectory split based on imaged speed');
            
            saveas(f2, sprintf('split_%d.fig',drawfigs));
        end
    end
    
    
end

    