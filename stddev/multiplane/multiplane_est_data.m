% 
% % % TODO:
% %     % At the end of each set of estimates, find region with minimum error
% %         % (normalised by num_trajectories) and reestimate other plane with
% %         % its focal length
%     
% 
% NUM_ITERATIONS = 3;
% 
% MODE_ALL_PARAM = 1; % Use all regions' estimated params as hypotheses
% MODE_CLUSTER_2 = 2; % Throw all into kmeans and cluster for 2 of them
% 
% WINDOW_SIZE = 100;
% WINDOW_DISTANCE = 75;
% 
% 
% MODE = MODE_CLUSTER_2;
% 
% multiplane_sim_data;
% 
% 
% % % now split all trajectories more than length 10 in half
% % tmpTraj = cell(2*length(imTraj),1);
% % 
% % trajLengths = cellfun(@length,tmpTraj);
% % 
% % num = 1;
% % for i=1:length(imTraj)
% %     t = imTraj{i};
% %     if(length(t) >= mean(trajLengths))
% %         tmpTraj{num} = t(:,1:ceil(length(t)/2));
% %         tmpTraj{num+1} = t(:,ceil(length(t)/2):end);
% %         num = num + 2;
% %     else
% %         tmpTraj{num} = t;
% %         num = num + 1;
% %     end
% % end
% % 
% % tmpTraj(num:end) = [];
% 
% allPoints = [imTraj{:}];
% 
% 
% mm = minmax([imTraj{:}]);
% regions = multiplane_gen_sliding_regions(mm, WINDOW_SIZE, imTraj, WINDOW_DISTANCE);
% 
% %% Now assign each trajectory a plane
% 
% labelling = cell(NUM_ITERATIONS,1);
% 
% for iteration = 1: NUM_ITERATIONS
%     
% %% Region based Estimation
%     output_params = cell(length(regions),1);
%     finalError    = cell(length(regions),1);
%     fullErrors    = cell(length(regions),1);
%     inits         = cell(length(regions),1);
%     for r=1:length(regions)
%         % For use with alpha expansion
%         %     plane_details.trajectories = traj2imc(multiplane_trajectories_for_region( tmpTraj, regions(r) ),1,1);
%         fprintf('Region: %d\n',r);
%         if length(regions(r).traj) < 1
%             regions(r).empty = 1;
%             fprintf('\tNo trajectories in region\n');
%             continue;
%         end
%         regions(r).empty = 0;
%         plane_details(r).trajectories = traj2imc( regions(r).traj,1,1 );
%         plane_details(r).imagewidth = abs(mm(1,2) - mm(1,1));
%         [ output_params{r}, finalError{r}, fullErrors{r}, inits{r}, E_angles{r}, E_focals{r} ] = multiplane_multiscaleSolver_using_imagewidth( 1, plane_details(r), 3, 10, 1e-12 );
%     end
% 
%     disp('ESTIMATES');
%     output_mat = cell2mat(output_params)
%     
%     if abs(round(output_mat(1,2))) == 101 || abs(round(output_mat(2,2))) == 101
%         disp('Error101');
%         save( sprintf('error101_iteration-%d_region-%d_%s',iteration,r,datestr(now, '_dd-mm-yy_HH-MM-SS')) );
%     end
%     
%     if MODE == MODE_CLUSTER_2
%         [~,hypotheses] = kmeans(output_mat,2);
%     else
%         hypotheses = output_mat;
%     end
% 
%     % Output estimation details.
%     % [plane_ids,confidence] = multiplane_planeids_from_traj( planes, tmpTraj );
%     disp('GROUND TRUTH');
%     anglesFromN(planeFromPoints(planes(1).camera),1,'degrees')
%     anglesFromN(planeFromPoints(planes(2).camera),1,'degrees')
%     
% %% Uncomment for alpha expansion
%     %   multiplane_alpha_expansion_script 
% 
% 
% 
% %% Dividing line for plane
%     %% Find line with minimum error
%     linePoints(1,:) = mm(1,1):10:mm(1,2);
%     linePoints(2,:) = repmat(mean(mm(2,:)),1,length(linePoints(1,:)));
%     angles = -89:89;
% 
%     [errors_1, errors_2] = multiplane_plane_dividing_line_c( imTraj, hypotheses, linePoints, angles );
%     %multiplane_script_plane_dividing_line( imTraj, hypotheses, linePoints, angles );
%     
%     minE1 = min(min(errors_1));
%     minE2 = min(min(errors_2));
% 
%     if minE1 < minE2
%         assignmentError = errors_1;
%         [row,col] = find(errors_1 == minE1,1,'first');
%     else
%         assignmentError = errors_2;
%         [row,col] = find(errors_2 == minE2,1,'first');
%     end
% 
%     centre = linePoints(:,row);
%     angle = angles(col);
% 
%     [sideTrajectories, trajIds] = multiplane_split_trajectories_for_line( imTraj, centre, angle );
%         
%     
%     history(iteration).output_mat   = output_mat;
%     history(iteration).fullErrors   = fullErrors;
%     history(iteration).centre       = centre;
%     history(iteration).angle        = angle;
%     history(iteration).regions      = regions;
%     clear regions;
%     
%     for r=1:2
%         regions(r).traj = sideTrajectories{r};
%         regions(r).centre = mean(minmax([sideTrajectories{r}{:}]),2);
%         regions(r).radius = max(range([sideTrajectories{1}{:}],2));
%     end
% end
% 
% 
%     
%% Make side-trajectory cells same order as hypotheses
    % work out errors for both sides given the 2 hypotheses
    side_errors = zeros(2,1);
    for i=1:2
        tmp_e1 = sum(errorfunc_traj( hypotheses(1,1:2), [5, hypotheses(1,3)], sideTrajectories{i} ).^2);
        tmp_e2 = sum(errorfunc_traj( hypotheses(2,1:2), [5, hypotheses(2,3)], sideTrajectories{1-(i-1)+1} ).^2);
        side_errors(i) = tmp_e1 + tmp_e2;
    end
    
    % Choose the hypotheses->trajectory pairing that minimises error.
    if side_errors(2) < side_errors(1)
    hypotheses = hypotheses(2:-1:1,:)

    end

%% Rectify using hypotheses
    % We can choose D as it merely sets scale, for comparison, set to the
    % same as planes(1).camera.
    [~,testD] = planeFromPoints( planes(1).camera, 4 );

    for i=1:2
        planes(i).rectified = backproj_c( hypotheses(i,1), hypotheses(i,2), testD, hypotheses(i,3), planes(i).image );
        planes(i).rectified_trajectories = cellfun(@(x) backproj_c( hypotheses(i,1), hypotheses(i,2), testD, hypotheses(i,3), x),sideTrajectories{i},'un',0);
    end
    
%% Line up planes
    % Now have 2 regions, but they don't necessarily line up - probably have
    % different D due to slope.
    
    % Get rectified speeds on both planes
    plane_mn_spd = zeros(2,1);
    for i=1:2
        plane_mn_spd(i) = nanmean(cellfun( @mean, cellfun(@traj_speeds,  planes(i).rectified_trajectories,'un',0)));
    end
    
    % The d-value for plane 2 that gives the same mean speed as plane 1 is
    % the right one.
    ratio = plane_mn_spd(2) / plane_mn_spd(1);
    new_d2 = testD./ratio;
    
    % Now re-rectify plane 2
    i = 2;
    planes(i).rectified = backproj_c( hypotheses(i,1), hypotheses(i,2), new_d2, hypotheses(i,3), planes(i).image );
    planes(i).rectified_trajectories = cellfun(@(x) backproj_c( hypotheses(i,1), hypotheses(i,2), new_d2, hypotheses(i,3), x),sideTrajectories{i},'un',0);
    
    drawPlane(planes(1).rectified,'',1,'b'); drawPlane(planes(2).rectified,'',0,'r');
    drawtraj( planes(1).rectified_trajectories,'',0,'b');
    drawtraj( planes(2).rectified_trajectories,'',0,'r');

    drawPlane(planes(1).camera,'',0,'c',0,'-');
    drawPlane(planes(2).camera,'',0,'m',0,'-');
    drawtraj(camTraj,'',0,'c',1,'--');
    saveas(gcf, 'comparison.fig');
    
    drawPlane(planes(1).image); drawPlane(planes(2).image,'',0,'r');
    drawtraj(sideTrajectories{1},'',0,'k');
    drawtraj(sideTrajectories{2},'',0,'r');
    multiplane_line_side( centre, angle, [0;0;0], 1, 'c', '-');
    saveas(gcf,'line_split.fig');
    
save data.mat;