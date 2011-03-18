function F = gp_iter_func_vary_n( x, coords )
%GP_ITER_FUNC 
%     x = ( nx, ny, nz );



F = [
      dist_eqn_vary_n( x, coords(:,1:2) );
      dist_eqn_vary_n( x, coords(:,3:4) );
      x(1)^2 + x(2)^2 + x(3)^2 - 1;
    ];

end

