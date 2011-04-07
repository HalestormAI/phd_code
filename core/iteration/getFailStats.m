function [successful, good_dist, good_barring_d, x_iter_mn] = getFailStats(failReasons, xiter_mat)
% Takes a matrix of failure reasons and outputs details such as successful
% convergences, etc.
%
%  INPUT:
%   failReasons     Matrix of failure reasons. Each row is an attempt.
%                   Columns are below. 0 == success, 1 == failure: 
%                   [ converge, valid_n, valid_d, valid_P, correct_P ]
%   xiter_mat       Matrix of all iteration results
%
%  OUTPUT:
%   successful      Ids of results for which the LM algorithm can converge
%   good_dist       Ids of results where P = \hat{P} (approx.)
%   good_barring_d  Ids of results for which \hat{n}, \hat{d} and \hat{P}
%                   are feasible
%   x_iter_mean     Mean plane (in ``iter'' format) from those for which
%                   \hat{n}, \hat{d} and \hat{P} are feasible

    successful     = find(~failReasons(:,1));
    good_dist      = successful(~failReasons(successful,5));
    good_barring_d = find(~sum(failReasons(:,[1,2,4]),2));
    if isempty(good_barring_d),
        err = MException('IJH:FAILS:EMPTY','No attempts passed n,P feasibility.');
        throw( err );
    end        
    x_iter_mn      = mean(xiter_mat(good_barring_d,:),1);
end