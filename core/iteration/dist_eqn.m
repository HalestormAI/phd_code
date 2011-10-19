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
end

