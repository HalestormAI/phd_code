function distances = findRotationParamsForCompare( r, C_a, C_e )

    %% Perform rotations as per r
    rotx = makehgtform( 'xrotate', r(1) );
    roty = makehgtform( 'yrotate', r(2) );
    rotz = makehgtform( 'zrotate', r(3) );
    t    = makehgtform( 'translate', r(4:end) );
    rot = rotx*roty*rotz*t;
    
    C_e_rot = rot(1:3,1:3)*C_e;
    
    %% Convert endpoint arrays to cell for faster processing
    C_comb      = [ C_a ; C_e_rot ];
    C_comb_cell = num2cell( C_comb ,1 );
    
    %% For each cell_a, find dist from cell_e
    distances = sum(cellfun(@(x) vector_dist( x(1:2),x(3:4) ), C_comb_cell )) / (size(C_a,2)/2)
    dlmwrite('myfile.txt', C_e_rot, 'delimiter', '\t', ...
             'precision', 6)
    
%     drawcoords3( C_e_rot, '',1,'g',0,'*')
%     drawcoords3( C_a, '',0,'r',0,'o')
end