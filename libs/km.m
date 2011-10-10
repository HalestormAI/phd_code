% [newctrs, ctrssize, quality] =
%       km(data, ctrs, maxiters, callback)
%
% K-means clustering algorithm. This function takes a set of spatial
% data and an initial set of centers, and performs the k-means
% algorithm.
%
% Inputs:
%   data     -- [n x d] matrix of data to cluster
%   ctrs     -- [k x d] matrix of initial centers
%   maxiters -- maximum number of iterations to perform (default 100)
%   callback -- a callback function (name) to be called with each
%               successive iteration of the algorithm. The callback
%               will be called with the following syntax:
%               eval([callback, '(current_ctrs, data, iteration)']);
%
% Outputs:
%   newctrs  -- [k d] matrix of the centers the algorithm found
%   ctrssize -- the number of datapoints assigned to each center
%   quality  -- vector of the k-means quality for each iteration of
%               the algorithm. length(quality) = number of iterations
%               this algorithm actually performed.
%
% $Revision: 1.5 $
% $Date: 2004/05/26 14:28:35 $
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
function [newctrs, ctrssize, quality] = ...
    km(data, ctrs, maxiters, callback)
    error(nargchk(2, 5, nargin));

    if nargin < 3 maxiters = 100; end
    if nargin < 4 callback = 0; end;

    [k, d] = size(ctrs);
    n = size(data, 1);

    quality = [];

    % pre-compute the square of each data point
    x2 = sum(data .* data, 2);
    x2 = repmat(x2, [1 k]); % size(x2) == [n k]

    lastCS = 1; cs = 1; % initial conditions

    for iter = 1:maxiters % do it *at most* maxiters times
        if (callback ~= 0)
            eval([callback, '(ctrs, data, iter);']);
        end;

        xc = data * ctrs'; % data times centers; size(xc) == [n k]

        % square each center
        c2 = sum(ctrs .* ctrs, 2);
        c2 = repmat(c2, [1 n]); % size(c2) == [k n]

        % distance^2 between each center & data point
        d2 = x2 - 2*xc + c2'; % size(d2) == [n k]

        lastCS = cs;
        if (min(size(d2)) == 1)
            md = d2;
            cs = ones(size(d2));
        else
            [md, cs] = min(d2'); % find the center for each datapt
            md = md';
            cs = cs';
        end;
        % md holds distance^2 from each datapt to its closest center
        % cs holds the index of the center closest to each datapt

        quality(iter) = sum(md);

        if (iter > 1)
            if (lastCS == cs) % check if the algorithm has converged
                break;
            end;
        end;

        % now we know the closest center for each datapt (in cs), so
        % we need to use each datapt to update the cluster centers
        for center = 1:k
            assigned = find(cs == center);
            asize = size(assigned, 1);
            if asize == 1
                ctrs(center,:) = data(assigned, :);
            elseif asize ~= 0
                ctrs(center,:) = sum(data(assigned, :)) / asize;
            end;
            center = center + 1;
        end;
    end;

    if (callback ~= 0)
        eval([callback, '(ctrs, data, ''finish'')']);
    end;

    % find the size of each center
    for i = 1:k
        ctrssize(i) = sum(cs == i);
    end;

    newctrs = ctrs;

