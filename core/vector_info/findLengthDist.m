function [mu,sigma,lengths,f,histInfo] = findLengthDist( im_coords, drawit )

if nargin  < 2,
    drawit = 1;
end

%Find std dev of all lengths
% First, find lengths
lengths = zeros(1,size(im_coords,2)/2);
for i=1:2:size(im_coords,2),
    lengths( (i+1)/2 ) = vector_dist( im_coords(:,i), im_coords(:,i+1) );
end

sigma = std( lengths );
mu = mean( lengths );

[counts, boundaries] = hist(lengths,25);
histInfo = struct('counts',counts,'boundaries',boundaries);
if drawit || (nargin < 2 && nargout == 0),
    f=figure;
    bar(boundaries,counts);
else
    f = 0;
end
