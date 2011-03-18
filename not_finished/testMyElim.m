function out = testMyElim( in )

% in is a 3x3 matrix:
% [x1,y1,z1]
% [x2,y2,z2]
% [x3,y3,z3]

x = in(:,1);
y = in(:,2);
z = in(:,3);


%% Get b:c ratio
alpha = x(1)/x(2);
alpha2 = x(1)/x(3);

% x1.a + y1.b + z1.c = k (1)
% x2.a + y2.b + z2.c = k (2)
% x3.a + y3.b + z3.c = k (3)

% x4 = alpha*x(2) - x(1); % Should be 0
y4 = alpha*y(2) - y(1);
z4 = alpha*z(2) - z(1);

% y4.b + z4.c = alpha*k-k (4)

% x5 = alpha2*x(3) - x(1); % Should be 0
y5 = alpha2*y(3) - y(1);
z5 = alpha2*z(3) - z(1);

% y5.b + z5.c = alpha2*k-k (5)

% coeff c from (4)
bc_ratio = -(y4*z5*alpha - y4*z5 - z4*y5*alpha + z4*y5) / (y5*alpha - y5 - alpha2*y4 + y4)
%-------

%% Now get a:b ratio
gamma  = z(1)/z(2);
gamma2 = z(1)/z(3);

x4 = gamma*x(2) - x(1);
y4 = gamma*y(2) - y(1);
% z4 = gamma*z(2) - z(1) % Should be 0


x5 = gamma2*x(3) - x(1);
y5 = gamma2*y(3) - y(1);
% z5 = gamma2*z(3) - z(1) % Should be 0

ab_ratio = -(-x4 * gamma2 + x4 + x5 * gamma - x5) / (-y4 * gamma2 + y4 + y5 * gamma - y5)

out = [ ab_ratio;1;bc_ratio ];