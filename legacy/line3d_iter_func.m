function F = line3d_iter_func( x, p )
%GP_ITER_FUNC 
%     x = ( t,x,y,z );
% Ensure n is unit.
F = [
      linefunc3d( [x(1),x(2)], p(1,:) );
      linefunc3d( [x(1),x(3)], p(2,:) );
      linefunc3d( [x(1),x(4)], p(3,:) );
    ];
end

