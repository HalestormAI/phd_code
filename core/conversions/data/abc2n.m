function [n,d] = abc2n( abc, retd )

if nargin < 2,
    retd = 0;
end

d = 1/norm(abc(1:3));
n = abc(1:3).*d;

if nargout < 2 && retd,
     n = [d,n];
end