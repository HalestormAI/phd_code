function C_ids = mpid2cid( M )
% Converts a set of midpoint ids to their respective vector endpoint ids
%
%  INPUT:
%    mpts       The set of midpoint ids
%
%  OUTPUT:
%    C_ids      The set of coordinate ids

    C_ids = sort([2.*M-1,2.*M]);

end