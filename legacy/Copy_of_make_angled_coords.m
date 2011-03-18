function [ coords ] = make_angled_coords( theta, d, l, num_coords )

    MAX_ATTEMPTS = 100;

    % set default number of coords to generate
    if nargin < 4,
        num_coords = 8;
    end
    
    % Make n
    n = [ 0 ; sin(theta) ; cos(theta) ];
    
    coords = zeros( 3, num_coords );
    
    
    for i=1:2:num_coords,
        % Make initial coord (from which to calculate a distance)
        % Pick any x (from simple case where n is normal to x)
        x = round( rand(1) * 200 );
        % pick a y
        y = round( rand(1) * 200 );
        % using y and n, compute z
        z = n(2) * y / n(3);
        
        v1 = [ x ; y ; z ];
        coords(:,i) = v1;
        
        % now compute other vector at distance l from v1
        
        done = 0;
        root_attempts = 0;
        disc_attempts = 0;
        while done ~= 1,
            % pick a new y and get z
            y = round( rand(1) * 200)
            z = n(2) * y / n(3)

            % now need to get x, s.t. distance(v1,v2) = l
            % eqn 1:  (x1 - x2)^2 = l^2 - (y1-y2)^2 - (z1-z2^2)
            % Get the RHS of eqn 1.
            dy = v1(2) - y;
            dz = v1(3) - z;
            rhs = l^2 - dy^2 - dz^2;

            % Get a, b and c for quadratic eqn, expand & rearrange eqn 1:
            % eqn 2:  x2^2 - 2x1x2 + x1^2 - l^2 + (y1-y2)^2 + (z1-z2^2)
            a = 1;
            b = 2 * v1(1);
            c = v1(1)^2 - l^2 + (v1(2)-y)^2 + (v1(3) - z)^2;
            
            % check the eqn has real roots if not, try new numbers
            disc = b^2 - 4*a*c
            if disc_attempts < MAX_ATTEMPTS && disc < 0,
                disc_attempts = disc_attempts + 1;
                continue;
            elseif disc < 0,
                disp( 'Too many attempts finding real roots. Giving up. Try a larger l' );
                return;
            end
            
            % We should be able to get roots, so find them :)
            roots = quadformula( a, b, c );
            
            % Check to see which root to use by plugging it in and checking
            % l against dist (v1, v2)
            v2 = [ roots(1) ; y ; z ];
            dist = vector_dist( v1,v2 );
            if round(dist) == round( l ),
                x = roots(1);
            else
                v2 = [ roots(2) ; y ; z ];
                dist2 = vector_dist( v1,v2 );
                
                if round(dist2) == round( l ),
                    x = roots(2);
                else
                    disp( 'neither root is correct for l :(' );
                    l
                    dist
                    dist2
                    return;
                end
            end
                
            v2 = [ x ; y ; z ];
            
            
            % We now have x, so leave the while loop
            done = 1;
        end
        
        coords(:,i+1) = v2;
    end
    
    