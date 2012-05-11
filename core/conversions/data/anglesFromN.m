function [theta, psi] = anglesFromN( N, asVec, units,offset_on )

if nargin < 3 || strcmp(units,'radians')
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

if nargin == 4 && ~offset_on
    theta = acFunc( N(3) );
else
    theta = offset-acFunc( N(3) );
end

if theta == 0
    psi = asFunc( -N(1) );
else
    psi = asFunc( -N(1) / sFunc(theta) );
end

if(nargin >= 2 && asVec == 1)
    theta = [theta ,psi];
end