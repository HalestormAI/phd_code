load students003;

lengths = cellfun(@(x) size(x,2), trajectories);
[~,sortedIds] = sort(lengths,'descend');
longestIds = sortedIds(1:20);
imtraj = traj2imc(trajectories(longestIds),1,1)
figure;
% drawcoords( imtraj,'',0,'k' );

