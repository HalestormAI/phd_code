function m = minor( S, i, j )

% Remove row i and column j from matrix
S(i,:) = [ ];
S(:,j) = [ ];

% Find the determinant
m = - det( S );

