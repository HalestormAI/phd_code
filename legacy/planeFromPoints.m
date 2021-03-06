function [n,d] = planeFromPoints( C, NUM_POINTS )

if nargin < 2,
    NUM_POINTS = 3;
end
% Pick n points
ids = randi(size(C,2),1,NUM_POINTS);

% For coeffecient matrix
cs = [C(:,ids);ones(1,NUM_POINTS)]';

% Use singular value decomposition to get coeffs
[U,S,V] = svd( cs );
n = V(1:3,end);
n = n/norm(n);
d = V(4,end);