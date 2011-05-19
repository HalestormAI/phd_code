% function centers = ...
%       gmeans(data, alpha, splitMethod, testMethod, callback)
%
% This function implements the g-means algorithm that uses
% 1-dimensional projection for its hypothesis tests. Centers are
% split, and the split is kept when it appears that the data owned by
% the original center is actually not one Gaussian.
%
% Input parameters:
%   data -- the data to cluster
%   alpha -- the confidence parameter to use for each statistical test
%            (default = 0.001)
%   splitMethod --
%       'random': random splitting (introduces nondeterminism)
%       'pca'   : largest eigenvector splitting using Matlab's
%                 eigendecomposition (default)
%   testMethod --
%       'gamma': use the G-means test statistic based on the gamma distribution
%       'ad'   : use the Anderson-Darling test statistic (default)
%   callback -- a callback function (name) to be called with each
%               successive iteration of the algorithm. The callback
%               will be called with the following syntax:
%               eval([callback, '(current_ctrs, data, iteration)']);
% Outputs:
%   centers -- the final set of centers
%
% $Revision: 1.4 $
% $Date: 2004/05/26 14:25:06 $
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
% If you use this code, please let me know, and please cite the paper:
%   @inproceedings{ hamerly03learning,
%       author = "Greg Hamerly and Charles Elkan",
%       title = "Learning the $k$ in $k$-means",
%       booktitle = "Advances in Neural Information Processing Systems",
%       volume = "17",
%       note = "To appear",
%       year="2003"
%   }
function centers = ...
    gmeans(data, alpha, splitMethod, testMethod, callback)
    if (nargin < 5) callback = 0;        end;
    if (nargin < 4) testMethod = 'ad';   end; % default: Anderson-Darling
    if (nargin < 3) splitMethod = 'pca'; end; % default: use PCA splitting
    if (nargin < 2) alpha = 0.001;   end; % default: alpha = 0.1%

    if (strcmp(testMethod, 'ad')) % find the anderson-darling critical value
        adcv = get_ad_cv(1 - alpha);
    end;

    % be quiet about Ritz values when doing eigenvalue decomposition
    opts.disp = 0; 

    [n, d] = size(data);
    ctrs = mean(data); % start with one center at the mean
    oldK = size(ctrs, 1);
    newK = 0;

    centerId = 0;
    rejectedSplits = []; % centers we should not split again
    centerIds = [centerId];

    iter = 0;

    while (oldK ~= newK)
        iter = iter + 1;
        if (callback ~= 0)
            eval([callback, '(ctrs, data, iter);']);
        end;

        oldK = size(ctrs, 1);
        newCtrs = [];
        newCtrIds = [];

        labels = findlabels(ctrs, data);

        for i = 1:oldK
            m(i) = sum(labels == i);
        end;

        for i = 1:oldK
            c = ctrs(i,:);

            % do not re-consider splits which have already
            % been rejected
            if (sum(rejectedSplits == centerIds(i)) > 0)
                newCtrs = [newCtrs; c];
                newCtrIds = [newCtrIds; centerIds(i)];
                continue;
            end;
        
            if (m(i) == 0) % delete centers with zero member points
                continue;
            elseif (m(i) == 1) % special case for centers with one member point
                newCtrs = [newCtrs; c];
                newCtrIds = [newCtrIds; centerIds(i)];
                continue;
            end;

            cdata = data(labels == i, :);
            cdist = distortion(cdata);

            % if the distortion is too small, then don't try to split
            if (cdist < eps)
                newCtrs = [newCtrs; c];
                newCtrIds = [newCtrIds; centerIds(i)];
                continue;
            end;

            covariance = cov(cdata);

            % RANDOM initialization
            if (strcmp(splitMethod, 'random'))
                offset = (rand(1,d)-0.5)*sqrt(trace(covariance))*0.1;
            % PCA initialization
            else
                % get the principal component
                [eigvecs, eigvals] = eig(covariance);
                [eigval, maxNdx] = max(diag(eigvals));
                eigvec = eigvecs(:,maxNdx);
                offset = eigvec' * sqrt(2 * eigval / pi);
            end;

            % create the two child centers
            ci = [c - offset; c + offset];

            % run k-means for 2 centers
            fc = km(cdata, ci);

            % project the data down to one dimension, onto the vector
            % connecting the two centers
            v = fc(1,:) - fc(2,:);
            pdata = cdata * v'; pfc = fc * v';
            mu = mean(pdata); sigma = std(pdata);

            % if sigma is too small in 1-d, then don't accept the split
            if (sigma < eps)
                newCtrs = [newCtrs; c];
                newCtrIds = [newCtrIds; centerIds(i)];
                continue;
            end;

            pdata = (pdata - mu) ./ sigma;
            pfc = (pfc - mu) ./ sigma;


            lab = findlabels(pfc, pdata);

            % if there are too few points in the cluster, then don't accept the
            % split
            if ((sum(lab == 1) == 0) || (sum(lab == 2) == 0))
                newCtrs = [newCtrs; c];
                newCtrIds = [newCtrIds; centerIds(i)];
                continue;
            end;

            keepSplit = 0;
            if (strcmp(testMethod, 'ad')) % Anderson-Darling statistical test
                a2 = andersondarling(pdata);
                if (a2 >= adcv)
                    keepSplit = 1;
                end;
            else % G-means statistical test based on the Gamma distribution
                dataC1 = pdata(lab == 1) - pfc(1);
                dataC2 = pdata(lab == 2) - pfc(2);

                r = sum(dataC1 .* dataC1) + sum(dataC2 .* dataC2);

                gamma = length(pdata) * (pi - 2) - 4;
                beta = 1/pi;
                prob = gamcdf(r, gamma, beta);

                if (prob < alpha)
                    keepSplit = 1;
                end;
            end;

            if (keepSplit == 1)
                newCtrs = [newCtrs; fc];
                newCtrIds = [newCtrIds; centerId + 1; centerId + 2];
                centerId = centerId + 2;
            else
                newCtrs = [newCtrs; c];
                newCtrIds = [newCtrIds; centerIds(i)];
                rejectedSplits = union(rejectedSplits, centerIds(i));
            end;
        end;

        newK = size(newCtrs, 1);

        % run k-means on all centers and all data to update the fit
        ctrs = km(data, newCtrs);
        centerIds = newCtrIds;
    end;

    if (callback ~= 0)
        eval([callback, '(ctrs, data, ''finish'')']);
    end;

    centers = ctrs;

