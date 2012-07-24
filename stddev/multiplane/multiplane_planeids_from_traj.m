function [plane_ids,confidence] = multiplane_planeids_from_traj( planes, traj )

    plane_ids  = NaN.*ones(length(traj),1);
    confidence = zeros(length(traj),2);

    for t=1:length(traj)
%         fprintf('Trajectory %d\n',t);
       [plane_ids(t), confidence(t,:)] = planeIdFromTraj( planes, traj{t} ); 
    end

    function [on,confidences] = planeIdFromTraj( planes, traj )
        confidences = zeros(1,length(planes));
        
        for p=1:length(planes)
            
            bounds = minmax(planes(p).image);
            
            in = zeros(size(traj,2),1);
            parfor tp=1:size(traj,2)
                xok = traj(1,tp) >= bounds(1,1) && traj(1,tp) <= bounds(1,2);
                yok = traj(2,tp) >= bounds(2,1) && traj(2,tp) <= bounds(2,2);
                if xok && yok
                    in(tp) = 1;
                end
            end
%             fprintf('\tIn: %d, Total: %d\n',sum(in),size(traj,2));
            confidences(p) = sum(in)/size(traj,2);
        end
        
        [~,on] = max(confidences);
    end 
end