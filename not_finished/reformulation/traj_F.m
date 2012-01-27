
    function tF = traj_F( traj, idx, x, isfirst, func_handle )
    
        if nargin < 5 || isempty(func_handle)
            func_handle = @traj_dist_eqn;
        end
        
        
    
        tF = zeros(1,length(traj)/2);
        for i=1:2:length(traj)
            tF((i+1)/2) = func_handle( x, traj(:,i:i+1),  idx, isfirst );
        end
    end