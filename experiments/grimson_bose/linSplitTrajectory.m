function [pieces, quality] = linSplitTrajectory( traj )

    pieces = {};
    quality = [];

    st_pt = 1;
    while st_pt<length(traj)
        for nd_pt=length(traj):-1:(st_pt+1)
            % Try to fit line
            t = traj(:,st_pt:nd_pt);
            p = polyfit(t(1,:),t(2,:), 1);
            
            ploty = polyval(p, t(1,:));
            
            % RMS line-fitting error
            r = sqrt(mean((ploty-t(2,:)).^2));
            
            if r < 0.02*trajPixelLength(t)
                st_pt = nd_pt-1;
                pieces{end+1} = t;
                quality(end+1) = r;
                break;
            end
        end
        st_pt = st_pt + 1;
    end
    
end
