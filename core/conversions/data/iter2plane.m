function plane = iter2plane( p, n, alpha )
% Converts an iteration vector to a plane structure
%  Can take the parameters individually or as an iteration vector.
%
%  INPUT:
%    p      Either an iteration vector or d.
%   *n      If "p" is used as "d", 3x1 column vector representing "n".
%   *alpha  If "p" is used as "d", the normalisation coefficient, alpha.
%
%  OUTPUT:
%    plane  A plane structure: { d, n, alpha }
if nargin == 3,
    plane = struct( 'd', p, 'n', n, 'alpha', alpha);
elseif nargin == 1,
    plane = struct( 'd', p(1), 'n', (p(2:4)./norm(p(2:4)))', 'alpha', p(5) );
end