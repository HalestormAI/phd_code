function [ obj ] = quadformula( a,b,c )
%QUADFORMULA Summary of this function goes here
%   Detailed explanation goes here

disc = b^2 - 4*a*c;

if disc < 0,
    disp( 'No Real Roots :(' );
    return;
end

x1 = ( -b + sqrt(disc) ) / (2*a);
x2 = ( -b - sqrt(disc) ) / (2*a);

obj = [x1, x2];