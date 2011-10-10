function out = dist_eqn( x, p )
%DIST_EQN Args:
%           x = ( d, nx, ny, nz, l );
%           p = ( x1, y1 ; x2, y2 );

x1 = p(1,1);
y1 = p(2,1);
x2 = p(1,2);
y2 = p(2,2);

a     = x(1);
b     = x(2);
c     = x(3);
alpha = x(4);
% l     = x(5);

% 
beta = c/alpha;
% 

Z1 = 1 / (alpha*(a*x1 + b*y1) + c);
Z2 = 1 / (alpha*(a*x2 + b*y2) + c);
X1 = x1*alpha*Z1;
X2 = x2*alpha*Z2;
Y1 = y1*alpha*Z1;
Y2 = y2*alpha*Z2;

out = ((X1-X2)^2 + (Y1-Y2)^2 + (Z1-Z2)^2) - 1;

% lambda1 = alpha*(a*x1 + b*y1) + c;
% lambda2 = alpha*(a*x2 + b*y2) + c;
% 
% out = ( (alpha*D*x1/lambda1)-(alpha*D*x2/lambda2) )^2 + ( (alpha*D*y1/lambda1)-(alpha*D*y2/lambda2) )^2 + ( (D/lambda1)-(D/alpha) )^2 - l^2;

% d = x(1);
% nx = x(2);
% ny = x(3);
% nz = x(4);
% l = 1;
% alpha = x(5);
% 
% Z1 = d / (alpha*x1*nx + alpha*y1*ny + nz);
% Z2 = d / (alpha*x2*nx + alpha*y2*ny + nz);
% X1 = alpha*Z1*x1;
% X2 = alpha*Z2*x2;
% Y1 = alpha*Z1*y1;
% Y2 = alpha*Z2*y2;
% 
% beta = 
% 
% 
% out = sqrt((X1-X2)^2 + (Y1-Y2)^2 + (Z1-Z2)^2)-1;

% 
% Z1 = d / (alpha*x1*nx + alpha*y1*ny + nz);
% Z2 = d / (alpha*x2*nx + alpha*y2*ny + nz);
% X1 = alpha*Z1*x1;
% X2 = alpha*Z2*x2;
% Y1 = alpha*Z1*y1;
% Y2 = alpha*Z2*y2;
% 
% out = sqrt( (X1-X2)^2 + (Y1-Y2)^2 + (Z1-Z2)^2 ) - 1;

% BEFORE PUTTING nz BACK IN: d ^ 2 * (x1 ^ 2) / ((x1 * nx) + (y1 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) ^ 2 - 0.2e1 * d ^ 2 * x1 * x2 / ((x1 * nx) + (y1 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) / ((x2 * nx) + (y2 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) + d ^ 2 * (x2 ^ 2) / ((x2 * nx) + (y2 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) ^ 2 + d ^ 2 * (y1 ^ 2) / ((x1 * nx) + (y1 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) ^ 2 - 0.2e1 * d ^ 2 * y1 * y2 / ((x1 * nx) + (y1 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) / ((x2 * nx) + (y2 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) + d ^ 2 * (y2 ^ 2) / ((x2 * nx) + (y2 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) ^ 2 + 0.9e1 * d ^ 2 / ((x1 * nx) + (y1 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) ^ 2 - 0.18e2 * d ^ 2 / ((x1 * nx) + (y1 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) / ((x2 * nx) + (y2 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) + 0.9e1 * d ^ 2 / ((x2 * nx) + (y2 * ny) - sqrt((1 - nx ^ 2 - ny ^ 2))) ^ 2

%out = d ^ 2 * (x1 ^ 2) / ((x1 * nx) + (y1 * ny) - nz) ^ 2 - 0.2e1 * d ^ 2 * x1 * x2 / ((x1 * nx) + (y1 * ny) - nz) / ((x2 * nx) + (y2 * ny) - nz) + d ^ 2 * (x2 ^ 2) / ((x2 * nx) + (y2 * ny) - nz) ^ 2 + d ^ 2 * (y1 ^ 2) / ((x1 * nx) + (y1 * ny) - nz) ^ 2 - 0.2e1 * d ^ 2 * y1 * y2 / ((x1 * nx) + (y1 * ny) - nz) / ((x2 * nx) + (y2 * ny) - nz) + d ^ 2 * (y2 ^ 2) / ((x2 * nx) + (y2 * ny) - nz) ^ 2 + 0.9e1 * d ^ 2 / ((x1 * nx) + (y1 * ny) - nz) ^ 2 - 0.18e2 * d ^ 2 / ((x1 * nx) + (y1 * ny) - nz) / ((x2 * nx) + (y2 * ny) - nz) + 0.9e1 * d ^ 2 / ((x2 * nx) + (y2 * ny) - nz) ^ 2 - l^2

% Before removing l.
%out = d ^ 2 / (nx * x1 + ny * y1 + nz) ^ 2 * x1 ^ 2 - 2 * d ^ 2 / (nx * x1 + ny * y1 + nz) * x1 / (nx * x2 + ny * y2 + nz) * x2 + d ^ 2 / (nx * x2 + ny * y2 + nz) ^ 2 * x2 ^ 2 + d ^ 2 / (nx * x1 + ny * y1 + nz) ^ 2 * y1 ^ 2 - 2 * d ^ 2 / (nx * x1 + ny * y1 + nz) * y1 / (nx * x2 + ny * y2 + nz) * y2 + d ^ 2 / (nx * x2 + ny * y2 + nz) ^ 2 * y2 ^ 2 + d ^ 2 / (nx * x1 + ny * y1 + nz) ^ 2 - 2 * d ^ 2 / (nx * x1 + ny * y1 + nz) / (nx * x2 + ny * y2 + nz) + d ^ 2 / (nx * x2 + ny * y2 + nz) ^ 2 - l ^ 2;

%out = sqrt(d ^ 2 * (alpha ^ 2) * ((2 * x2 * nx * y2 * ny) - (2 * x1 * nx * y2 * ny) - (2 * y1 * ny * x2 * nx) - (2 * alpha ^ 2 * x1 * x2 * y1 * ny ^ 2 * y2) + (2 * x1 * nx * y1 * ny) - (2 * alpha ^ 2 * y1 * y2 * x1 * nx ^ 2 * x2) + (x1 ^ 2) - (2 * y1 * y2) + (alpha ^ 2 * y2 ^ 2 * x1 ^ 2 * nx ^ 2) + (alpha ^ 2 * x2 ^ 2 * y1 ^ 2 * ny ^ 2) + (alpha ^ 2 * x1 ^ 2 * y2 ^ 2 * ny ^ 2) + (x2 ^ 2) + (y1 ^ 2) + (y2 ^ 2) + 0.2e1 * alpha * x1 * x2 * y2 * ny * sqrt((1 - nx ^ 2 - ny ^ 2)) + 0.2e1 * alpha * x1 * x2 * y1 * ny * sqrt((1 - nx ^ 2 - ny ^ 2)) - 0.2e1 * alpha * (x1 ^ 2) * y2 * ny * sqrt((1 - nx ^ 2 - ny ^ 2)) - 0.2e1 * alpha * (x2 ^ 2) * y1 * ny * sqrt((1 - nx ^ 2 - ny ^ 2)) + 0.2e1 * alpha * y1 * y2 * x2 * nx * sqrt((1 - nx ^ 2 - ny ^ 2)) - 0.2e1 * alpha * (y2 ^ 2) * x1 * nx * sqrt((1 - nx ^ 2 - ny ^ 2)) - 0.2e1 * alpha * (y1 ^ 2) * x2 * nx * sqrt((1 - nx ^ 2 - ny ^ 2)) + 0.2e1 * alpha * y1 * y2 * x1 * nx * sqrt((1 - nx ^ 2 - ny ^ 2)) - (2 * x1 * x2) + (alpha ^ 2 * y1 ^ 2 * x2 ^ 2 * nx ^ 2) - (y2 ^ 2 * nx ^ 2) - (y1 ^ 2 * nx ^ 2) - (x2 ^ 2 * ny ^ 2) - (x1 ^ 2 * ny ^ 2) + (2 * x1 * x2 * ny ^ 2) + (2 * y1 * y2 * nx ^ 2)) / (-(alpha * x1 * nx) - (alpha * y1 * ny) + sqrt((1 - nx ^ 2 - ny ^ 2))) ^ 2 / (-(alpha * x2 * nx) - (alpha * y2 * ny) + sqrt((1 - nx ^ 2 - ny ^ 2))) ^ 2) - 1;

% out = (d ^ 2 * alpha ^ 2 * (2 * x2 * nx * y2 * ny + 2 * alpha * x1 ^ 2 * y2 * ny * nz - 2 * x1 * nx * y2 * ny - 2 * y1 * ny * x2 * nx - 2 * alpha ^ 2 * x1 * x2 * y1 * ny ^ 2 * y2 - 2 * alpha * x1 * x2 * y1 * ny * nz - 2 * alpha * x1 * x2 * y2 * ny * nz + 2 * x1 * nx * y1 * ny + 2 * alpha * x2 ^ 2 * y1 * ny * nz + 2 * alpha * y1 ^ 2 * x2 * nx * nz - 2 * alpha ^ 2 * y1 * y2 * x1 * nx ^ 2 * x2 - 2 * alpha * y1 * y2 * x1 * nx * nz - 2 * alpha * y1 * y2 * x2 * nx * nz + 2 * alpha * y2 ^ 2 * x1 * nx * nz - 2 * x1 * x2 * nz ^ 2 + alpha ^ 2 * y2 ^ 2 * x1 ^ 2 * nx ^ 2 + alpha ^ 2 * x2 ^ 2 * y1 ^ 2 * ny ^ 2 - 2 * x1 * nx ^ 2 * x2 - 2 * y1 * y2 * nz ^ 2 + alpha ^ 2 * x1 ^ 2 * y2 ^ 2 * ny ^ 2 + y2 ^ 2 * ny ^ 2 + y1 ^ 2 * ny ^ 2 + x1 ^ 2 * nx ^ 2 + x1 ^ 2 * nz ^ 2 + x2 ^ 2 * nx ^ 2 + x2 ^ 2 * nz ^ 2 + y1 ^ 2 * nz ^ 2 + y2 ^ 2 * nz ^ 2 - 2 * y1 * ny ^ 2 * y2 + alpha ^ 2 * y1 ^ 2 * x2 ^ 2 * nx ^ 2) / (alpha * x1 * nx + alpha * y1 * ny + nz) ^ 2 / (alpha * x2 * nx + alpha * y2 * ny + nz) ^ 2);

end

