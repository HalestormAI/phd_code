function J = calc_traj_jacobian( iter, traj )

    pointPairs = reshape(traj,[2,2,length(traj)/2]);

    J = zeros(size(pointPairs,3),4);
    for i=1:size(pointPairs,3)
        J(i,:) = calc_jacob_row(iter,pointPairs);
    end
end