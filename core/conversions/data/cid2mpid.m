function m = cid2mpid( c )
% Coord index to midpoint index
    m = unique(ceil(c/2));
end