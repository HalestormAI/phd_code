function angle = angleError( n1, n2, mirr, unit )
% Returns the angle difference, in degrees, between two normal
% column-vectors n1 and n2
%
% Input:
%
%   n1              The first column vector
%   n2              The second column vector
%  [mirr=0]         Allow mirroring (e.g. the error plot looks thus: /\).
%  [unit='degrees'] Set the units: 'degrees' or 'radians'.


if nargin < 4 || strcmpi(unit,'degrees')
    cfunc = @acosd;
    fixDiff = 90;
elseif strcmpi(unit,'radians')
    cfunc = @acos;
    fixDiff = pi/2;
else 
    error('Invalid unit choice given');
end


angle = real(cfunc(dot(n1,n2) / ( norm(n1)*norm(n2) ) ));

if nargin >= 3 && mirr == 1,
    angle = fixDiff - abs(fixDiff - angle);
end

