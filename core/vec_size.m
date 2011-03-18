function [ s ] = vec_size( v )
%VEC_SIZE Summary of this function goes here
%   Detailed explanation goes here

cumsum = 0;

maxsz = max( size(v) );

for i=1:maxsz,
 cumsum = cumsum + v(i)^2;
end

s = sqrt(cumsum);
end

