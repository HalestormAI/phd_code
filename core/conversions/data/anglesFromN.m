function [theta, psi] = anglesFromN( N, asVec )


N = N ./ norm(N);
% "pi -"  is fix for us finding the angle pointing DOWN due to neg Z
theta = pi-acos( N(3) );
if theta == 0
    psi = asin( -N(1) );
else
    psi = asin( -N(1) / sin(theta) );
end

if(nargin == 2 && asVec == 1)
    theta = [theta ,psi];
end