function plane = iter2plane( p, n, alpha )
    
if nargin == 3,
    plane = struct( 'd', p, 'n', n, 'alpha', alpha);
elseif nargin == 1,
    plane = struct( 'd', p(1), 'n', (p(2:4)./norm(p(2:4)))', 'alpha', p(5) );
end