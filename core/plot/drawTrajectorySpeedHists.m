function f = drawTrajectorySpeedHists( traj, traj2 )
% Draws histograms for speeds inside each trajectory

    f = figure;
    lengths = cellfun(@vector_dist,traj,'uniformoutput',false);
    if nargin ==2
        lengths2 = cellfun(@vector_dist,traj2,'uniformoutput',false);
    end
    maxFD = 0;
    for I=1:length(lengths)
        subplot(2,3,I);
        [hL,hX] = hist(lengths{I}./mean(lengths{I}));
        norm_hL = hL./sum(hL);
        
        if max(norm_hL) > maxFD,
            maxFD = max(norm_hL);
        end
        
        if nargin ==2
            [hL2] = hist(lengths{I}./mean(lengths2{I}),hX);
            norm_hL2 = hL2./sum(hL2);
        
            if max(norm_hL2) > maxFD,
                maxFD = max(norm_hL2);
            end
        end
        
        if nargin == 2
            plotY = [norm_hL;norm_hL2]'
        else
            plotY = norm_hL;
        end
        bar( hX, plotY );
        axis([ 0 2 0 1]);
        xlabel('Normalised Length');
        ylabel('Frequency Density');
        title(sprintf('Trajectory contains %d vectors',length(lengths{I})));
    end
    set(findall(gcf,'Type','axes'),'YLim',[0 maxFD])
    suplabel('Distributions of normalised vector speeds for used trajectories','t')
end