function [mu,sigma,lengths,f,histInfo] = findLengthDist( im_coords, drawit, colour )

if nargin  < 2,
    drawit = 1;
end

%Find std dev of all lengths
% First, find lengths
lengths = vector_dist( im_coords );

sigma = std( lengths );
mu = mean( lengths );

[counts, boundaries] = hist(lengths,25);
histInfo = struct('counts',counts,'boundaries',boundaries);
if drawit || (nargin < 2 && nargout == 0),
    if drawit == 1
        f=figure;
    end
    if nargin < 3,
        bar(boundaries,counts);
    else
        bar(boundaries,counts,'FaceColor',colour);
    end
else
    f = 0;
end
