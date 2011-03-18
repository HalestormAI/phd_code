function n = findNormalFromH( H )
S = H' * H - eye(size(H));

maxS = zeros(3,1);

for i=1:3,
    maxS(i) = abs(S(i,i));
end

[DONOTWANT, bestS] = max(maxS);

if bestS == 1,
    n_a = [ 
            S(1,1) ;
            S(1,2) + sqrt(minor(S,3,3));
            S(1,3) + sign(S,2,3)*sqrt(minor(S,2,2))
            
           ];
       
%    n_a = n_a ./ norm(n_a)
       
    n_b = [ 
            S(1,1) ;
            S(1,2) - sqrt(minor(S,3,3));
            S(1,3) - sign(S,2,3)*sqrt(minor(S,2,2))
            
           ];
  %  n_b = n_b ./ norm(n_b)
elseif bestS == 2,
    n_a = [ 
            S(1,2) + sqrt(minor(S,3,3));
            S(2,2) ;
            S(2,3) - sign(S,1,3)*sqrt(minor(S,1,1))
            
           ];
%    n_a = n_a ./ norm(n_a)
    n_b = [ 
            S(1,2) - sqrt(minor(S,3,3));
            S(2,2) ;
            S(2,3) + sign(S,1,3)*sqrt(minor(S,1,1))
            
           ];
 %   n_b = n_b ./ norm(n_b)
else
    n_a = [ 
            S(1,3) + sign(S,1,2)*sqrt(minor(S,2,2));
            S(2,3) + sqrt(minor(S,1,1));
            S(3,3) ;      
           ];
  %  n_a = n_a ./ norm(n_a)
    n_b = [ 
            S(1,3) - sign(S,1,2)*sqrt(minor(S,2,2));
            S(2,3) - sqrt(minor(S,1,1));
            S(3,3) ;      
           ];
   % n_b = n_b ./ norm(n_b)
end
    if n_a(3) > 0,
        n_a = -n_a;
    end
    if n_b(3) > 0,
        n_b = -n_b;
    end
    a_x = 0;
    a_y = 0;
    a_z = 0;
    
 %   rotx = [ 1 0 0; 0 cos(a_x) sin(a_x); 0 -sin(a_x) cos(a_x) ];
  %  roty = [ cos(a_y) 0 -sin(a_y); 0 1 0; sin(a_y) 0 cos(a_y) ];
 %   rotz = [ cos(a_z) sin(a_z) 0; -sin(a_z) cos(a_z) 0; 0 0 1 ];
    
  %  rots = rotz*rotx;
    
    n_a =   (n_a./ norm(n_a));
    
    n = struct( 'a', n_a  , 'b', n_b ./ norm(n_b) );
       
    function s = sign( S, i, j )
        
        m = minor( S, i ,j );
        if m >= 0,
            s = 1;
        else
            s = -1;
        end
        
    end

    function m = minor( S, i, j )
        % Remove row i and column j from matrix
        S(i,:) = [ ];
        S(:,j) = [ ];

        % Find the determinant
        m = - det( S );
    end
       
end