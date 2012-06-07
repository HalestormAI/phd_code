function cost = cluster_trajectory_distance_cost( t1, t2 )

    cost = NaN*ones(length(t1),length(t2));

    for i=1:length(t1)
        for j=1:length(t2)
            cost(i,j) = vector_dist(t1(:,i),t2(:,j));
        end
    end
end
