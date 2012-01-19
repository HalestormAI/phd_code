pass_results = find(exitflag > 0);
pass_ids = post_SIDS(exitflag > 0);

for i=1:min(10,length(find(exitflag > 0)))
    
    iter = x_iter{pass_ids(i)}(1:4);
    est_plane = find_real_world_points(imPlane,iter2plane(iter));
    f = drawPlane( est_plane );
    
    est_traj = cellfun( @(x) find_real_world_points(x,iter2plane(iter)),imTraj,'uniformoutput',false);
    scatter3(est_traj{1}(1,:),est_traj{1}(2,:),est_traj{1}(3,:));
    cellfun(@(x) drawcoords3(x,'',0,'b'),est_traj);
    saveas( f,sprintf('estimplane_bestfval_%d.fig',i) )
end