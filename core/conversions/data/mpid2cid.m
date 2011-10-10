function c = mpid2cid( m )
% Converts a set of midpoint ids to their respective vector endpoint ids
%
%  INPUT:
%    m      The set of midpoint ids
%
%  OUTPUT:
%    c      The set of coordinate ids
    if iscol(m),
        m = m';
    end
    c = sort([2*m-1,2*m]);
end