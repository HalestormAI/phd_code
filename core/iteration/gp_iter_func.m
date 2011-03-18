function F = gp_iter_func( x, coords )
%GP_ITER_FUNC 
%     x = ( d, nx, ny, nz );
% Ensure n is unit.


% for each column in coords, add a row to F.
F = zeros( size(coords,2)/2, 1 );

for i=1:2:size(coords,2),
    F((i+1)/2) = dist_eqn( x, coords(:,i:i+1) );
end


unit_check = x(2)^2 + x(3)^2 + x(4)^2 - 1 ;
F = [
         F;
         abs(unit_check);
         x(4) > 0;
     ];

end

