function s = make_plane( a, b, c, d )
%MAKE_PLANE Take Coefficients from planar equation in euclidean form, and
%return Hessian Normal form: n.x = -d
%   Returns: STRUCT( n, d )

nx = a / ( sqrt( a^2 + b^2 + c^2 ) );
ny = b / ( sqrt( a^2 + b^2 + c^2 ) );
nz = c / ( sqrt( a^2 + b^2 + c^2 ) );

n = [ nx ; ny ; nz ]

p = d / ( sqrt( a^2 + b^2 + c^2 ) );

s = struct( 'n', n, 'd', p  );