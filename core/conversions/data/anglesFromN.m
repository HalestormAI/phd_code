function [theta, psi] = anglesFromN( N, asVec, units )

if nargin < 3
    asFunc = @asin;
    acFunc = @acos;
    sFunc  = @sin;
    offset = pi;
elseif strcmp(units,'degrees')
    asFunc = @asind;
    acFunc = @acosd;
    sFunc  = @sind;
    offset = 180;
end


N = N ./ norm(N);
% "pi -"  is fix for us finding the angle pointing DOWN due to neg Z
theta = offset-acFunc( N(3) );
if theta == 0
    psi = asFunc( -N(1) );
else
    psi = asFunc( -N(1) / sFunc(theta) );
end

if(nargin == 2 && asVec == 1)
    theta = [theta ,psi];
end