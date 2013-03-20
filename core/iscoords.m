function isit = iscoords( traj )

    if size(traj,2) < 2
        isit = 0;
        return
    end
    v1 = traj(:,2:2:end);
    v2 = traj(:,3:2:end);

    if size(v1,2) > size(v2,2) 
        v1(:,end) = [];
    elseif size(v2,2) > size(v1,2) 
        v2(:,end) = [];
    end
    
    isit = isempty(find(v1 ~= v2,1,'first'));