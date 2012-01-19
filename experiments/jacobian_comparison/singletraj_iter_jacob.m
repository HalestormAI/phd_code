function [F,J] = singletraj_iter_jacob( x, traj )

    F = zeros(1,length(traj)/2);
    for i=1:2:length(traj)
        F((i+1)/2) = singletraj_dist_eqn( x, traj(:,i:i+1) );
    end
    J = calc_traj_jacobian( x, traj );