function [ Z1 ] = z1( x1, y1, nx, ny, nz, d )
%Z1 Summary of this function goes here
%   Detailed explanation goes here

%x1,y1,nx,ny,nz,d
Z1 = d / (x1*nx + y1*ny + nz );