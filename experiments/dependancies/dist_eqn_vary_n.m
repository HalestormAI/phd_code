function out = dist_eqn( x, p )
%DIST_EQN Args:
%           x = ( d, nx, ny, nz, l );
%           p = ( x1, y1 );

x1 = p(1,1);
y1 = p(2,1);
x2 = p(1,2);
y2 = p(2,2);

d = 5000;
nx = x(1);
ny = x(2);
nz = x(3);
l = 175;


% BEFORE PUTTING nz BACK IN: d ^ 2 * (x1 ^ 2) / ((x1 * nx) + (y1 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) ^ 2 - 0.2e1 * d ^ 2 * x1 * x2 / ((x1 * nx) + (y1 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) / ((x2 * nx) + (y2 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) + d ^ 2 * (x2 ^ 2) / ((x2 * nx) + (y2 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) ^ 2 + d ^ 2 * (y1 ^ 2) / ((x1 * nx) + (y1 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) ^ 2 - 0.2e1 * d ^ 2 * y1 * y2 / ((x1 * nx) + (y1 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) / ((x2 * nx) + (y2 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) + d ^ 2 * (y2 ^ 2) / ((x2 * nx) + (y2 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) ^ 2 + 0.9e1 * d ^ 2 / ((x1 * nx) + (y1 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) ^ 2 - 0.18e2 * d ^ 2 / ((x1 * nx) + (y1 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) / ((x2 * nx) + (y2 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) + 0.9e1 * d ^ 2 / ((x2 * nx) + (y2 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) ^ 2

%out = d ^ 2 * (x1 ^ 2) / ((x1 * nx) + (y1 * ny) - nz) ^ 2 - 0.2e1 * d ^ 2 * x1 * x2 / ((x1 * nx) + (y1 * ny) - nz) / ((x2 * nx) + (y2 * ny) - nz) + d ^ 2 * (x2 ^ 2) / ((x2 * nx) + (y2 * ny) - nz) ^ 2 + d ^ 2 * (y1 ^ 2) / ((x1 * nx) + (y1 * ny) - nz) ^ 2 - 0.2e1 * d ^ 2 * y1 * y2 / ((x1 * nx) + (y1 * ny) - nz) / ((x2 * nx) + (y2 * ny) - nz) + d ^ 2 * (y2 ^ 2) / ((x2 * nx) + (y2 * ny) - nz) ^ 2 + 0.9e1 * d ^ 2 / ((x1 * nx) + (y1 * ny) - nz) ^ 2 - 0.18e2 * d ^ 2 / ((x1 * nx) + (y1 * ny) - nz) / ((x2 * nx) + (y2 * ny) - nz) + 0.9e1 * d ^ 2 / ((x2 * nx) + (y2 * ny) - nz) ^ 2 - l^2
out = d ^ 2 / (nx * x1 + ny * y1 + nz) ^ 2 * x1 ^ 2 - 2 * d ^ 2 / (nx * x1 + ny * y1 + nz) * x1 / (nx * x2 + ny * y2 + nz) * x2 + d ^ 2 / (nx * x2 + ny * y2 + nz) ^ 2 * x2 ^ 2 + d ^ 2 / (nx * x1 + ny * y1 + nz) ^ 2 * y1 ^ 2 - 2 * d ^ 2 / (nx * x1 + ny * y1 + nz) * y1 / (nx * x2 + ny * y2 + nz) * y2 + d ^ 2 / (nx * x2 + ny * y2 + nz) ^ 2 * y2 ^ 2 + d ^ 2 / (nx * x1 + ny * y1 + nz) ^ 2 - 2 * d ^ 2 / (nx * x1 + ny * y1 + nz) / (nx * x2 + ny * y2 + nz) + d ^ 2 / (nx * x2 + ny * y2 + nz) ^ 2 - l ^ 2;


end

