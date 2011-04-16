function mps = coord2midpt( imc )
% Converts a set of 3xn vectors in endpoint coordinate form to a set of 
% 3x0.5n vector midpoints.
%
%  INPUT:
%    imc        The set of vector endpoints
%
%  OUTPUT:
%    mps        The set of midpoints

mps = (imc(:,1:2:size(imc,2)) + imc(:,2:2:size(imc,2))) ./ 2;
    

end