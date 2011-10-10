function plane = iter2plane( p, alpha )
% Converts an iteration vector to a plane structure
%  Can take the parameters individually or as an iteration vector.
%
%  INPUT:
%    p      Either an iteration vector or n.
%   *alpha  If "p" is used as "n", the normalisation coefficient, alpha.
%
%  OUTPUT:
%    plane  A plane structure: { [a,b,c]', alpha }
if nargin == 3,
    plane = struct( 'n', p, 'alpha', alpha);
elseif nargin == 1,
    if length(p) == 4,
        plane = struct( 'abc',p(1:3),'n', (p(1:3)./norm(p(1:3)))','a',p(1),'b',p(2),'c',p(3), 'alpha', p(4) );
    else
        error('Plane should be 1x4 vector');
    end
end