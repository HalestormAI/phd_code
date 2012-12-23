function N = normalFromAngle( theta, psi, base )
% Creates a normal vector from yaw and AoE
% INPUT:
%   theta   AoE
%   psi     Yaw
%   base    "degrees" (default) or "radians" 

if nargin == 1 && length(theta) == 2
    psi = theta(2);
    theta = theta(1);
end

if nargin < 3,
    base = 'degrees';
end

if strcmp(base,'degrees'),
    theta = deg2rad(theta);
    psi   = deg2rad(psi);
end

N =  -[ sin(psi)*sin(theta);
       cos(psi)*sin(theta);
       cos(theta)
     ];
