function [parallels, ls] = createLineStructs( lines_mat, im )

for i=1:size(lines_mat,2),
   
    ls(i) = struct( 'start', lines_mat(1:2,i), 'end', lines_mat(3:4,i) );
    fprintf( 'Line %d:\n', i);
    ls(i).start
    ls(i).end
    
end


parallels(1,:) = [ ls(1), ls(3) ];
parallels(2,:) = [ ls(2), ls(4) ];

figure, imshow( im );

drawLine( parallels(1,1), 'r' );
drawLine( parallels(1,2), 'r' );
drawLine( parallels(2,1), 'b' );
drawLine( parallels(2,2), 'b' );


    function drawLine( ln, col )
        if nargin < 2,
            col = 'b';
        end
        line( [ ln.start(1) ln.end(1) ], [ ln.start(2) ln.end(2) ] , 'Color', col );
    end

end