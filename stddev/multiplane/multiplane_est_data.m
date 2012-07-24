% multiplane_sim_data;
% 
% % now split all trajectories more than length 10 in half
% tmpTraj = cell(2*length(imTraj),1);
% 
% trajLengths = cellfun(@length,tmpTraj);
% 
% num = 1;
% for i=1:length(imTraj)
%     t = imTraj{i};
%     if(length(t) >= mean(trajLengths))
%         tmpTraj{num} = t(:,1:ceil(length(t)/2));
%         tmpTraj{num+1} = t(:,ceil(length(t)/2):end);
%         num = num + 2;
%     else
%         tmpTraj{num} = t;
%         num = num + 1;
%     end
% end
% 
% tmpTraj(num:end) = [];
% 
% 
% multiplane_sim_data;
% mm = minmax([imTraj{:}]);
% regions = multiplane_gen_sliding_regions(mm, 150, imTraj)

output_params = cell(length(regions),1);
finalError    = cell(length(regions),1);
fullErrors    = cell(length(regions),1);
inits         = cell(length(regions),1);
% 
% % Use only one trajectory
% for t=1:length(tmpTraj)
%     plane_details.trajectories = traj2imc(tmpTraj(t),1,1);
%     
%     % NEED TO MODIFY multiscaleSolver so that it looks at more than one position.
%     [ output_params{t}, finalError{t}, fullErrors{t}, inits{t} ] = multiplane_multiscaleSolver( 1, plane_details, 3, 10, 1e-12 );
% end

% Region based
% regions = multiplane_generate_regions( tmpTraj );
for r=1:length(regions)
%     plane_details.trajectories = traj2imc(multiplane_trajectories_for_region( tmpTraj, regions(r) ),1,1);
    fprintf('Region: %d\n',r);
    if length(regions(r).traj) < 1
        fprintf('\tNo trajectories in region\n',r);
        continue;
    end
    plane_details.trajectories = traj2imc( regions(r).traj,1,1 );
    [ output_params{r}, finalError{r}, fullErrors{r}, inits{r} ] = multiplane_multiscaleSolver( 1, plane_details, 3, 10, 1e-12 );
end

disp('ESTIMATES');
output_mat = cell2mat(output_params)

% Output estimation details.
% [plane_ids,confidence] = multiplane_planeids_from_traj( planes, tmpTraj );
disp('GROUND TRUTH');
anglesFromN(planeFromPoints(planes(1).camera),1,'degrees')
anglesFromN(planeFromPoints(planes(2).camera),1,'degrees')
% [output_mat(plane_ids==1,1:2)]'
% [output_mat(plane_ids==2,1:2)]'