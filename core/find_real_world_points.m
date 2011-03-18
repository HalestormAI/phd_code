function [ POINTS ] = find_real_world_points( points, plane )
%FIND_REAL_WORLD_POINTS Summary of this function goes here
%   Detailed explanation goes here

POINTS = zeros(3 , size(points,2) );
for i=1:size(points,2)
    
    POINTS(:,i) = find_real_world_point( points(:,i), plane );
    
end
