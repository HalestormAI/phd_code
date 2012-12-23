
    function D = distance_from_plane( n, d, p )
        
        root = sqrt( sum(n.^2) );
        D = abs(sum(n.*p) - d) / root;
    end