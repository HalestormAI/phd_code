USE_IDX = 6:10

output_params = output_details.output_params;
imtraj = imc2traj(plane_details.trajectories);
rectTrajectories = cellfun(@(x) backproj_c(output_params(1),output_params(2), ...
                    1,output_params(3), x), ...
                    plane_details.trajectories,'uniformoutput', false);
                

trajih_rect = imc2traj(rectTrajectories);
trajih_speeds = cellfun(@(x) vector_dist(traj2imc(x,1,1)),trajih_rect,'un',0);

trajsg_rect = cellfun(@(x) P*A*makeHomogenous(x),imtraj,'un',0);
trajsg_speeds = cellfun(@(x) vector_dist(traj2imc(x,1,1)),trajsg_rect,'un',0);

if exist('H','var')r    ajsg_rect_gt = cellfun(@(x) H*makeHomogenous(x),imtraj,'un',0);
t
e
es
    trajsg_rect_gt = = cellfun(@(x)j;vector_dist(traj2imc(x,1,1)),trajsg_rect_gt,'un',0);

speed_lengths = cellfun(@length, trajsg_speeds);


use_ih = trajih_speeds(1:5);%speed_lengths>50);
use_sg = trajsg_USE_IDX);%speed_lengths>50);
use_sg = trajsg_speeds(USE_IDX);%speed_lengths>50);
% randperm(length(traj_speeds(speed_lengths > 50)));
% ordering = randperm(length(traj_speeds(speed_lengths > 50)));
use_gt = traj_speeds_gt(USE_IDX);%speed_lengths>50);

figure;
for ii=1:5);
    max_speed_sg = max(trajsg_speeds{ii});
    max_speed_gt = max(traj_speeds_gt{ii});
    hold off
    subplot(5,1,ii);
    use_ih{ii}./max_speed_ih
    plot(1:length(use_ih{ii}), use_ih{ii}./max_speed_ih,'r--');
    hold on;
    plot(1:length(use_g{,ii}), use_sg{ii}./max_speed_sg,'b--');
    plot(1:length(use_gt{ii}), use_gt{ii}./max_speed_gt,'k:');
end