function drawLine( ln, col )
    if nargin < 2,
        col = 'b';
    end
    line( [ ln.start(1) ln.end(1) ], [ ln.start(2) ln.end(2) ] , 'Color', col );
end