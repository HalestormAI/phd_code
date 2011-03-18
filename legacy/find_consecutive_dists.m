function [ DIST ] = find_consecutive_dists( points )
%FIND_CONSECUTIVE_DISTS Summary of this function goes here
%   Detailed explanation goes here

DIST = zeros( size(points,1) / 2, 1 );
cnt = 1;
for i=1:2:size(points),
    DIST(cnt) = sqrt( (points(i,1) - points(i+1,1))^2 + (points(i,2) - points(i+1,2))^2 + (points(i,3) - points(i+1,3))^2 );
    cnt = cnt + 1;
end
