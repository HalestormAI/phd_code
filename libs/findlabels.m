% function labels = findlabels(ctrs, data)
%
% This function finds the 'label' for each datapoint (the center that
% each datapoint is closest to).
%
% Input parameters:
%   ctrs -- the k-means centers (size k x d)
%   data -- the data to find labels for (size n x d)
%
% Outputs:
%   labels -- the vector of n integer labels, one for each datapoint
%
% $Revision: 1.2 $
% $Date: 2004/05/26 13:15:27 $
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
function labels = findlabels(ctrs, data)
    k = size(ctrs, 1);
    n = size(data, 1);

    x2 = sum(data .* data, 2);
    x2 = repmat(x2, [1 k]); % [n k]

    % data times centers
    xc = data * ctrs'; % [n k]

    % square each center
    c2 = sum(ctrs .* ctrs, 2);
    c2 = repmat(c2, [1 n]); % [k n]

    % distance^2 between each center & data point
    d2 = x2 - 2*xc + c2'; % [n k]

    if (min(size(d2)) == 1)
        md = d2;
        labels = ones(size(d2));
    else
        [md, labels] = min(d2'); % find the center for each datapt
        md = md';         % squared distance from each datapt to its closest center
        labels = labels'; % indexes of the center closest to each datapt
    end;

