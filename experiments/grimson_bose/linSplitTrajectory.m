function [pieces, quality] = linSplitTrajectory( traj )

    MIN_LENGTH = 4;

%     pieces = {};
%     quality = [];

    pieces = cell( length(traj),1 );
    quality = Inf*ones( length(traj), 1);
    
    st_pt = 1;
%     textprogressbar('Splitting Linear Trajectories...');
    counter = 1;
    while st_pt<length(traj)
        for nd_pt=length(traj):-1:(st_pt+MIN_LENGTH)
            % Try to fit line
            t = traj(:,st_pt:nd_pt);
            p = linefit(t(1,:),t(2,:));
            
            ploty = polyval(p, t(1,:));
            
            % RMS line-fitting error
            r = sqrt(mean((ploty-t(2,:)).^2));
            
            if r < 0.02*trajPixelLength(t)
                st_pt = nd_pt-1;
%                 pieces{end+1} = t;
%                 quality(end+1) = r;

                pieces{counter} = t;
                quality(counter) = r;
                counter = counter + 1;
                break;
            end
        end
%         textprogressbar(100*(st_pt/length(traj)));
        st_pt = st_pt + 1;
    end
%     textprogressbar('Done.');


    pieces((counter):end) = [];
    quality((counter):end) = [];
    
    
    function p = linefit( x, y)
        p = [ones(length(x),1) ,reshape(x,length(x),1)] \ reshape(y,length(y),1);
        p = p(end:-1:1)';
    end

end
