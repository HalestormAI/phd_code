function [ dist ] = vector_dist( v1, v2 )
%VECTOR_DIST Summary of this function goes here
%   Detailed explanation goes here

if nargin == 1,
    v2 = v1(:,2:2:end);
    v1 = v1(:,1:2:end);
end
if size(v1,1) ~= size(v2,1),
    error( 'v1 and v2 should be the same size. V1: %d, V2: %d', numel(v1), numel(v2) );
    return;
end

dist = sqrt( sum((v1-v2).*(v1-v2)) );
%dist = sqrt( (v1(1) - v2(1))^2 + ( v1(2) - v2(2))^2 + (v1(3) - v2(3))^2 );