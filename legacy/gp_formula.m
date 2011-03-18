function [ out ] = gp_formula( params, x1, y1, x2, y2 )
%GP_FORMULA Summary of this function goes here
%   Detailed explanation goes here

nx = params(1);
ny = params(2);
d = params(3);
l = params(4);
%nz = params(5);

nz = - sqrt( 1- nx^2 - ny^2 );

px1 = ( x1 * d ) / (x1*nx + y1*ny + nz );
px2 = ( x2 * d ) / (x2*nx + y2*ny + nz );
py1 = ( y1 * d ) / (x1*nx + y1*ny + nz );
py2 = ( y2 * d ) / (x2*nx + y2*ny + nz );
pz1 = d / (x1*nx + y1*ny + nz );
pz2 = d / (x2*nx + y2*ny + nz );

out = sqrt ( (px1 - px2)^2 + (py1 - py2)^2 + (pz1 - pz2)^2 ) - l;



end

