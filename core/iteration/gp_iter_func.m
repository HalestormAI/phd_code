function F = gp_iter_func( x, coords )
%GP_ITER_FUNC 
%     x = ( d, nx, ny, alpha );
% 

    % for each column in coords, add a row to F.
    F = zeros( size(coords,2)/2, 1 );
    %x(2:4) = x(2:4)./norm(2:4);
%     x(5) = -1;
    for i=1:2:size(coords,2),
        F((i+1)/2) = dist_eqn( x, coords(:,i:i+1) );
    end   
    unitn = x(2:4) ./ norm(x(2:4));
    
    %% Additional Constraints
%     F = sum(abs(F))/(size(coords,2)/2); % Reduce return value to single element
%     F = [F;abs(unitn(3)) > 0.999]; % Prevent n_z being 1
%     F = [F;x(1) < 1]; % % Prevent d becoming too small
%     F = [F;x(5)];
end
