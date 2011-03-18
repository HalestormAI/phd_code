function [A,unit_vector] = linefunc3d( ref_L, ref_R, dist )
% linefunc3d
%    2 points in 3d space and returns the line intersecting
%    them in vector form.
%
%    Input:
%       ref_L         Reference point 1        
%       ref_R         Reference point 2
%       dist          Extrapolation of line from point 2.
%
%    Output:
%       A             
%       unit_vector   The unit vector representing the line.
if ( iscol( ref_L ) && size(ref_L,1) < 3 ) || size(ref_L,2) < 3,
    ref_L(3) = 1;
end
if ( iscol( ref_R ) && size(ref_R,1) < 3 ) || size(ref_R,2) < 3,
    ref_R(3) = 1;
end

vector = (ref_L) - (ref_R);
separation = sqrt(vector(1)^2 + vector(2)^2 + vector(3)^2);
unit_vector = vector / separation;


A(1, :) = (-unit_vector * dist) + ref_R;
A(2, :) = ( unit_vector * dist) + ref_R;