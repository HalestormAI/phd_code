function [ c_ls_idx ] = find_correct_ls( c_n_ls, actual_l, tol, n_tol)
%UNTITLED8 Summary of this function goes here
%   Args:
%       n_ls        Values of L from feasible convergence points
%       c_idx       Indices of correct n's
%       actual_l    The correct value of L to test against
%       tol         Optional: The tolerance percentage for testing,  defaults to 1000 (0.1%)
%       n_tol       Optional: The abs difference tolerance, defaults to 10

if nargin < 1,
    help( find_correct_ls );
    error('Not enough args');
elseif nargin < 3,
    tol = 1000;
end
if nargin < 4,
    n_tol = 10;
end

l_diff = round( (c_n_ls - actual_l) .* tol) ./ tol;

c_ls_idx = find( abs(l_diff) < n_tol );

end

