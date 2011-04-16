function angle = angleError ( n1, n2 )
% Returns the angle difference, in degrees, between two normal
% column-vectors n1 and n2

angle = acosd(dot(n1,n2) / ( norm(n1)*norm(n2) ) ) ;
