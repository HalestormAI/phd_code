function [n,d] = planeFromPoints( C, NUM_POINTS )

if nargin < 2,
    NUM_POINTS = 3;
end
% % Pick n points
% ids = randi(size(C,2),1,NUM_POINTS);
% 
% % For coeffecient matrix
% cs = [C(:,ids);ones(1,NUM_POINTS)]';
% 
% % Use singular value decomposition to get coeffs
% [U,S,V] = svd( cs );
% n = V(1:3,end);
% n = n/norm(n);
A = C(:,1)-C(:,2);
B = C(:,3)-C(:,1);
n = cross(A,B)./norm(cross(A,B));
if n(3) > 0,
    n = n.*-1;
end
%d = V(4,end);

ds = zeros(1,NUM_POINTS);
for i=1:NUM_POINTS,
    ds(i) = n(1)*C(1,i) + n(2)*C(2,i) + n(3)*C(3,i);
end

d = mean(ds);