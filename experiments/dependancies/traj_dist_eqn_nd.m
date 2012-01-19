function out = traj_dist_eqn_nd( x, p, idx, isfirst )
%DIST_EQN Args:
%           x = ( d, nx, ny, nz, l );
%           p = ( x1, y1 ; x2, y2 );

x1 = p(1,1);
y1 = p(2,1);
x2 = p(1,2);
y2 = p(2,2);

nx     = x(1);
ny     = x(2);
nz     = x(3);%= sqrt(1 - nx^2 - ny^2);
d      = x(4);
alpha  = x(5);
% l     = x(5);

ratio = x(4+idx);

if nargin < 4 || ~isfirst
    l = ratio;
else
    l = 1;
end


Z1 = d / (alpha*x1*nx + alpha*y1*ny + nz);
Z2 = d / (alpha*x2*nx + alpha*y2*ny + nz);
X1 = alpha*Z1*x1;
X2 = alpha*Z2*x2;
Y1 = alpha*Z1*y1;
Y2 = alpha*Z2*y2;

out = sqrt( (X1-X2)^2 + (Y1-Y2)^2 + (Z1-Z2)^2 ) - l;

end


%% faster

% 
% Z1 = 1 / (x(4)*(x(1)*p(1,1) + x(2)*p(2,1)) + x(3));
% Z2 = 1 / (x(4)*(x(1)*p(1,2) + x(2)*p(2,2)) + x(3));
% 
% out = (((p(1,1)*x(4)*Z1)-(p(1,2)*x(4)*Z2))^2 + ((p(2,1)*x(4)*Z1)-(p(2,2)*x(4)*Z2))^2 + (Z1-Z2)^2) - l;