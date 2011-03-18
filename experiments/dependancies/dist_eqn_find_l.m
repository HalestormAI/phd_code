function out = dist_eqn_find_l( x, p )
%DIST_EQN Args:
%           x = ( d, nx, ny, nz );
%           p = ( x1, y1 ; x2, y2 );

x1 = p(1,1);
y1 = p(2,1);
x2 = p(1,2);
y2 = p(2,2);

d = x(1);
nx = x(2);
ny = x(3);
nz = x(4);

out = sqrt( d ^ 2 / (nx * x1 + ny * y1 + nz) ^ 2 * x1 ^ 2 - 2 * d ^ 2 / (nx * x1 + ny * y1 + nz) * x1 / (nx * x2 + ny * y2 + nz) * x2 + d ^ 2 / (nx * x2 + ny * y2 + nz) ^ 2 * x2 ^ 2 + d ^ 2 / (nx * x1 + ny * y1 + nz) ^ 2 * y1 ^ 2 - 2 * d ^ 2 / (nx * x1 + ny * y1 + nz) * y1 / (nx * x2 + ny * y2 + nz) * y2 + d ^ 2 / (nx * x2 + ny * y2 + nz) ^ 2 * y2 ^ 2 + d ^ 2 / (nx * x1 + ny * y1 + nz) ^ 2 - 2 * d ^ 2 / (nx * x1 + ny * y1 + nz) / (nx * x2 + ny * y2 + nz) + d ^ 2 / (nx * x2 + ny * y2 + nz) ^ 2);

end

