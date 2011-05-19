% function [dist, avgDist] = distortion(x)
%
% Find the distortion (sum of squared euclidean distances from the
% mean) for the given data.
% 
% Input parameters:
%   x -- the size [n d] matrix, where n is the number of data points
%        and d is the number of dimensions
%
% Outputs:
%   dist -- the total sum of squared distances of every point to the
%           mean of the data
%   avgDist -- the average (per-point) sum of squared distances of
%              every point to the mean of the data
%
% $Revision: 1.1 $
% $Date: 2003/11/20 19:43:42 $
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
function [dist, avgDist] = distortion(x)
    [n, d] = size(x);
    x = x - repmat(mean(x), n, 1);
    dist = sum(sum(x .* x));
    if (nargout > 1) avgDist = dist / n; end;

