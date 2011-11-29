function [theta, psi] = anglesFromN( N, asVec )


N = N ./ norm(N);

theta = abs(pi - acos( N(3) ));
if theta == 0
    psi = asin( -N(1) );
else
    psi = asin( -N(1) / ( sin(theta) ) );
end

if(nargin == 2 && asVec == 1)
    theta = [theta ,psi];
end