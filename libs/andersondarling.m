% function A2 = andersondarling(x)
%
% This function calculates the Anderson-Darling statistic for
% one-dimensional data, which can be used to test the data for
% normality. The Anderson-Darling statistic is in the class of ECDF
% statistics, which compare the empirical CDF (cumulative distribution
% function) of the given data against the known CDF for the
% distribution that the data is being fit to (in this case, the normal
% distribution).
%
% For details see Yew-Haur Lee's thesis, "Fisher Information Test of
% Normality":
% http://scholar.lib.vt.edu/theses/available/etd-82198-9530/unrestricted/ETD.PDF
%
% The formulas involved are:
%   A^2 = - 1/n * Sum(i, (2*i-1) * (ln(Z[i]) + ln(1 - Z[n+1-i]))) - n
% where Z_i = Phi((x_(i) - mean(x)) / std(x))
%   (see http://mathworld.wolfram.com/NormalDistributionFunction.html)
% and x_(i) is the ith order statistic of x.
%
% $Revision: 1.2 $
% $Date: 2003/11/25 11:22:19 $
% 
% Copyright (C) 2003  Greg Hamerly (ghamerly at cs dot ucsd dot edu)
% Released under the GNU GPL software license.
% http://www.gnu.org/copyleft/gpl.html

% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
% 02111-1307  USA
%
% If you use this code, please let me know.
function A2 = andersondarling(x)
    n = length(x);
    x = sort(x);

    z = normcdf(x, mean(x), std(x));
    z(z == 1) = 1 - eps; % avoid log of zero below
    z(z == 0) = eps;

    A2 = -sum( ...
                (2*(1:n) - 1)' .*  ...
                (log(z) + log(1 - z(n:-1:1)))  ...
             ) / n - n;

    % to correct or not to correct... that is the question
    %A2 = A2 * (1 + 4/n - 25 / (n*n));

% uncomment this function if you are using Octave
%function z = normcdf(x, mu, sigma)
    %z = normal_cdf(x, mu, sigma);
