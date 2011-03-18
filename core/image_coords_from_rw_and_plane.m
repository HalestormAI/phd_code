function [ im_points ] = image_coords_from_rw_and_plane( rw_points )
%IMAGE_COORDS_FROM_RW_AND_PLANE Summary of this function goes here
%   Detailed explanation goes here

%im_points = zeros( 2, size(rw_points,2) );
for i=1:size(rw_points,2),
    
    im_points(1,i) = rw_points(1,i) / rw_points(3,i);
%    im_points(2,i) = (plane.d / (rw_points(3,i)) - ( plane.n(1) * rw_points(1,i) ) / (rw_points(3,i)) - (plane.n(3))) / plane.n(2);
 %rw_points(2,i) 
    im_points(2,i) = rw_points(2,i) / rw_points(3,i);
end


    %y1_simple  = rw_points(2,i) / rw_points(3,i)    
    %y1_complex = (plane.d / (rw_points(3,i)) - ( plane.n(1) * rw_points(1,i) ) / (rw_points(3,i)) - (plane.n(3))) / plane.n(2)