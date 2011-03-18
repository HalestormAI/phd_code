function angle = angleError ( n1, n2 )
% Returns the angle difference, in degrees, between n1 and n2

angle = (rad2deg( acos(dot(n1,n2) / ( norm(n1)*norm(n2) ) ) ) );