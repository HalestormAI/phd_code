function [ c_ds_idx ] = find_correct_ds( n_ds, c_idx, actual_d, tol)
%UNTITLED8 Summary of this function goes here
%   Args:
%       n_ds        Values of D from feasible convergence points
%       c_idx       Indices of correct n's
%       actual_l    The correct value of D to test against
%       tol         Optional: The tolerance percentage for testing, defaults to 1000 (0.1%);

if nargin < 1,
    help( find_correct_ds );
    error('Not enough args');
elseif nargin < 4,
    tol = 1000;
end

c_n_ds = n_ds(c_idx);

d_diff = round( (c_n_ds - actual_d) .* tol) ./ tol;

c_ds_idx = find( d_diff == 0 );

end

