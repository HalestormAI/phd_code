function plane = iter2plane( p, n )
    
if nargin == 2,
    plane = struct( 'd', p, 'n', n );
elseif nargin == 1,
    plane = struct( 'd', p(1), 'n', p(2:4)' );
end