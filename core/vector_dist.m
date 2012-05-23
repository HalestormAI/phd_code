function [ dist ] = vector_dist( v1, v2 )
%VECTOR_DIST Summary of this function goes here
%   Detailed explanation goes here

if nargin == 1,
    v2 = v1(:,2:2:end);
    v1 = v1(:,1:2:end);
end

if ~numel(v1) && ~numel(v2)
    dist = NaN;
    return;
end

if size(v1,1) ~= size(v2,1) || size(v1,2) ~= size(v2,2),
    error('v1 & v2 should be same size. V1: (%d x %d), V2: (%d x %d)', ...
          size(v1,1), size(v1,2), size(v2,1), size(v2,2) );
end

if abs(size(v1,2)-size(v2,2)) == 1
    v1 = v1(:,1:end-1);
end

dist = sqrt( sum((v1-v2).*(v1-v2)) );
%dist = sqrt( (v1(1) - v2(1))^2 + ( v1(2) - v2(2))^2 + (v1(3) - v2(3))^2 );
