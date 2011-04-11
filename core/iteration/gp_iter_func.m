function F = gp_iter_func( x, coords )
%GP_ITER_FUNC 
%     x = ( d, nx, ny, alpha );
% 


    % for each column in coords, add a row to F.
    F = zeros( size(coords,2)/2, 1 );
    %x(2:4) = x(2:4)./norm(2:4);
    for i=1:2:size(coords,2),
        F((i+1)/2) = dist_eqn( x, coords(:,i:i+1) )*10;
    end
    
end
