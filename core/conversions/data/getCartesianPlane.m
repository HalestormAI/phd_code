function z = getCartesianPlane( x, y, d, n, c, minidx )

if nargin < 6,
    % First find best fitting coordinate to plane
    [minerror, minidx] = min(abs(n' * c(:,:) - d));
end
xx = c(:,minidx);

% Now sub into plane equation to get params.
z = ( n(3)*xx(3) - n(1)*(x - xx(1)) - n(2)*(y-xx(2)) ) / n(3);

