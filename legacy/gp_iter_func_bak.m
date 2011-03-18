function F = gp_iter_func( x, coords )
%GP_ITER_FUNC 
%     x = ( d, nx, ny, nz );


F = [
      dist_eqn( x, coords(:,1:2) );
      dist_eqn( x, coords(:,3:4) );
      dist_eqn( x, coords(:,5:6) );
      x(2)^2 + x(3)^2 + x(4)^2 - 1;
    ];

end

