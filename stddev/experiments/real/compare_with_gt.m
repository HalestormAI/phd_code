function compare_with_gt( trajectories, output_params, H, PA )

USE_IDX = 1:(min(15,length(trajectories)));

% output_params = output_details.output_params;
% trajectories = traj2imc(trajectories);
% rectTrajectories = cellfun(@(x) backproj_c(output_params(1),output_params(2), ...
%                     1,output_params(3), x), ...
%                     trajectories,'uniformoutput', false);
rectTrajectories = cellfun(@(x) backproj([output_params(1:2)], ...
                    [1,output_params(3)], x), ...
                    trajectories,'uniformoutput', false);
                
rectTrajectories = cellfun(@(x) x(1:2,:),rectTrajectories,'un',0');

trajih_speeds = cellfun(@(x) traj_speeds(x(1:2,(1:end))),rectTrajectories,'un',0);
use_ih = trajih_speeds(USE_IDX);%speed_lengths>50);

%% Ground-truth
if nargin >= 3
    if ischar(H)
        traj_rect_gt = PETSCalibrationParameters(H, trajectories);
    else
        traj_rect_gt = cellfun(@(x) H*makeHomogenous(x),trajectories,'un',0);
    end    
    traj_speeds_gt = cellfun(@(x) traj_speeds(x(:,1:end)),traj_rect_gt,'un',0);
    use_gt = traj_speeds_gt(USE_IDX);
end
% traj_speeds_im = cellfun(@(x) traj_speeds(x(:,1:2:end)),trajectories,'un',0);

%% Bose & Grimson
if nargin >= 4
    trajsg_rect = cellfun(@(x) PA*makeHomogenous(x),trajectories,'un',0);
    trajsg_speeds = cellfun(@(x) vector_dist(traj2imc(x(1:2,:),1,1)),trajsg_rect,'un',0);
    use_sg = trajsg_speeds(USE_IDX);%speed_lengths>50);
end

% use_im = traj_speeds_im(USE_IDX);


figure;
for ii=1:length(USE_IDX)
    hold off
    subplot(5,3,ii);
    max_speed_ih = nanmean(use_ih{ii});
    plot(1:length(use_ih{ii}), (use_ih{ii})./max_speed_ih,'r--');
    hold on;
    if nargin >= 3
        max_speed_gt = nanmean(use_gt{ii});
        plot(1:length(use_gt{ii}), (use_gt{ii})./max_speed_gt,'k-');
    end
    if nargin >= 4
        max_speed_sg = nanmean(use_sg{ii});
        plot(1:length(use_sg{ii}), (use_sg{ii})./max_speed_sg,'g--');
    end
    title(sprintf('use idx: %d',ii))
end