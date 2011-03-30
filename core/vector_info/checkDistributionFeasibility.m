function [baddist,numbad] = checkDistributionFeasibility( wc, MULT, TOL )
% Checks if the distribution of lengths in a world-coordinate set is
% feasible, that is, if the number of vectors of length mu(l)+MULT*sd(l)
% is greater than TOL.
%
% INPUT:
%   wc       The set of world coordinates.
%  [MULT]    The multiplier for comparison. Default: 10.
%  [TOL]     The number of vectors allowed. Default: 1.
%
% OUTPUT:
%   baddist  True if the distribution is INFEASIBLE. False otherwise.

if nargin < 2,
    MULT = 10;
end
if nargin < 3,
    TOL = 1;
end

[mu_lwc,sd_wcl,lengths] = findLengthDist( wc, 0 );
numbad = length(find(lengths > mu_lwc + MULT*sd_wcl ));
baddist = numbad > TOL;