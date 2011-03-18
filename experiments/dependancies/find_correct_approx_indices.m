function [ idx, r_correct ] = find_correct_approx_indices( r, n, threshold )
% Find results that converge to the exactly correct point (within tolerance)
%   INPUT:
%     r           The set of estimated normal column-vectors
%     n           The ground-truth
%     threshold   Multiplier before rounding
%
%   OUTPUT:
%     idx         Indices of correct r's
%     r_correct   Values of correct r's


if nargin < 2,
   error('Must provide a results set and correct normal');
elseif nargin < 3,
   threshold = 1000; 
else
    if threshold <= 0,
        error('Threshold must be a positive real number');
    end
end

% Round all results to the threshold
rminusn = round([ r(1,:) - n(1); r(2,:) - n(2); r(3,:) - n(3) ] .* threshold) ./ threshold;
r1 = find( rminusn(1,:) == 0 );
r2 = find( rminusn(2,:) == 0 );
r3 = find( rminusn(3,:) == 0 );

idx = intersect(r3, intersect(r1,r2));
r_correct = r(:, idx);

end

