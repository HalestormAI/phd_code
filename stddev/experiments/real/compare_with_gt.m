function compare_with_gt( trajectories, output_params, H )

USE_IDX = 1:(min(10,length(trajectories)));

% output_params = output_details.output_params;
% trajectories = traj2imc(trajectories);
% rectTrajectories = cellfun(@(x) backproj_c(output_params(1),output_params(2), ...
%                     1,output_params(3), x), ...
%                     trajectories,'uniformoutput', false);
rectTrajectories = cellfun(@(x) backproj([output_params(1:2)], ...
                    [1 -.005], x), ...
                    trajectories,'uniformoutput', false);
                
rectTrajectories = cellfun(@(x) x(1:2,:),rectTrajectories,'un',0');

trajectories{1}
rectTrajectories{1}
trajih_speeds = cellfun(@(x) traj_speeds(x(1:2,(1:2:end))),rectTrajectories,'un',0);

% trajsg_rect = cellfun(@(x) P*A*makeHomogenous(x),imtraj,'un',0);
% trajsg_speeds = cellfun(@(x) vector_dist(traj2imc(x,1,1)),trajsg_rect,'un',0);

if nargin == 3%exist('H','var')
    traj_rect_gt = cellfun(@(x) H*makeHomogenous(x),trajectories,'un',0);
% else
    
end
traj_speeds_gt = cellfun(@(x) traj_speeds(x(:,1:2:end)),traj_rect_gt,'un',0);
traj_speeds_im = cellfun(@(x) traj_speeds(x(:,1:2:end)),trajectories,'un',0);


use_ih = trajih_speeds(USE_IDX);%speed_lengths>50);
use_gt = traj_speeds_gt(USE_IDX);%speed_lengths>50);
use_im = traj_speeds_im(USE_IDX);


figure;
for ii=1:length(USE_IDX)
    max_speed_ih = max(use_ih{ii});
    max_speed_gt = max(use_gt{ii});
    max_speed_im = max(use_im{ii});
    hold off
    subplot(5,2,ii);
%     use_ih{ii}./max_speed_ih
    plot(1:length(use_ih{ii}), (use_ih{ii})./max_speed_ih,'r--');
    hold on;
%     plot(1:length(use_sg{ii}), use_sg{ii}./max_speed_sg,'b--');
    plot(1:length(use_gt{ii}), (use_gt{ii})./max_speed_gt,'k-');
%     plot(1:length(use_im{ii}), use_im{ii}./max_speed_im,'g-');
    title(sprintf('use idx: %d',ii))
end