function [ Z1 ] = z1( x1, y1, plane )
%Z1 Summary of this function goes here
%   Detailed explanation goes here

%x1,y1,nx,ny,nz,d

nx    = plane.n(1);
ny    = plane.n(2);
nz    = plane.n(3);
d     = plane.d;
alpha = plane.alpha;

Z1 = d / (alpha*x1*nx + alpha*y1*ny + nz );