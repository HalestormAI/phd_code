function dist = traj_speeds( t )

    t1 = t(:,2:end);
    t2 = t(:,1:end-1);

	dist = vector_dist( t1, t2 );
end