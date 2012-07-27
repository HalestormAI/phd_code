function mat = rotatemtx( drn, angle )
    mat = makehgtform(drn,angle);
    mat = mat(1:3,1:3);
    