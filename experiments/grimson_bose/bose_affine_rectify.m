function P = bose_affine_rectify( trajs,Gs )

    D_THRESH = 1000; % Threshold for parallel lines (3.3 - type 1)
    I_THRESH = 100; % Threshold for image-convergant lines (3.3 - type 2)

    % Now get the vanishing line using inv(G)
    p_v = [1;0];
    p_v_primes = NaN.*ones(2,length(p_v));
    
    for gid=1:length(Gs)
        g = Gs(gid);
        p_v_prime = g\p_v;
        
        % Handle degenerate case where lines are (near) parallel
        if d(p_v_prime, trajs{gid}) < D_THRESH
            p_v_primes(:,gid) = p_v_prime;
        end
    end
    
    % Remove all degenerate points (NaN)
    p_v_primes(isnan(p_v_primes)) = [];
    
    % Now take mean vanishing point to check type 2 degenerate cases
    mean_p_v_prime = mean(p_v_primes,2);
    
    % Check distances
    img_ds = Inf*ones(length(traj),1);
    for t=1:length(traj)
        img_ds(t) = d( mean_p_v_prime, traj{t} );
    end
    
    if max(img_ds) > I_THRESH
        error('Degenerate case - vanishing point in image');
        % TODO: Handle type 2 degenerate case better
    end
    
    
    vanishing_line = polyfit( p_v_primes(1,:), p_v_primes(2,:),1 );
    
    
    % Flesh out the projection matrix
    P = eye(3);
    P(3,:) = [vanishing_line,1];
    
    
    % Given a trajectory, `T` and the vanishing point, `v`, calculate the
    % mean euclidean distance between `v` and the endpoints of `T`.
    function dist = d( p, traj )
        d1 = norm(p-traj(:,1));
        d2 = norm(p-traj(:,2));
        
        dist = mean([d1,d2]);
    end
end