function [theta, psi] = anglesFromN( N, asVec )

    sz_n = 1;


theta = abs(pi - acos( N(3)/sz_n ));

psi = asin( -N(1)/sz_n / ( sin(theta) ) );

if(nargin == 2 && asVec == 1)
    theta = [theta ,psi];
end