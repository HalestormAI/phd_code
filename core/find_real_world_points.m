function [ POINTS ] = find_real_world_points( points, plane )
% Take points as 2xn matrix, take plane in struct form.

POINTS = zeros(3 , size(points,2) );
for i=1:size(points,2)
    
    POINTS(:,i) = find_real_world_point( points(:,i), plane );
    
end
