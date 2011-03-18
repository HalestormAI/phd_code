function [theta, psi] = anglesFromN( N, sz_n )

if nargin < 2,
    sz_n = 1;
end

theta = abs(pi - acos( N(3)/sz_n ));

psi = asin( -N(1)/sz_n / ( sin(theta) ) );
