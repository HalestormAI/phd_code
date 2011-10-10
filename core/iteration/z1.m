function [ Z1 ] = z1( x1, y1, plane )
%Z1 Summary of this function goes here
%   Detailed explanation goes here

%x1,y1,nx,ny,nz,d

a    = plane.a;
b    = plane.b;
c    = plane.c;
alpha = plane.alpha;
beta = c / alpha;

Z1 = 1 / (alpha*(x1*a + y1*b + beta ));