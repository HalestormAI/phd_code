function [n,d] = abc2n( abc )


d = 1/norm(abc(1:3));
n = abc(1:3).*d;