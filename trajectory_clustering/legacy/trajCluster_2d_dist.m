load students003;

lengths = cellfun(@(x) size(x,2), trajectories);
[~,sortedIds] = sort(lengths,'descend');
longestIds = sortedIds(1:20);

imtraj = trajectories(longestIds);
figure;
drawcoords( traj2imc(imtraj,1,1),'',0,'k' );

