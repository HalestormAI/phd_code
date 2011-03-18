function [ coords ] = make_noneven_angled_coords( n, d, l, noise_amount, num_coords )

    MAX_ATTEMPTS = 2000;

    % set default number of coords to generate
    if nargin < 4,
        num_coords = 8;
    end
    
    % Make n
    if vec_size(n) ~= 1,
        n = n ./ vec_size(n);
    end
    coords = zeros( 3, num_coords );
    
    
    lengths = normrnd( l, noise_amount, 1, num_coords/2 );
    
    for i=1:2:num_coords,
        % Make initial coord (from which to calculate a distance)
        % Pick any x (from simple case where n is normal to x)
        x = ( rand(1) * d );
        % pick a y
        y = ( rand(1) * d );
        % using x, y and n, compute z
        z = (d - n(2) * y - n(1) * x) / n(3);
        
        v1 = [ x ; y ; z ];
        coords(:,i) = v1;
        
        done = 0;
        attempts = 0;
        while done ~= 1,
            attempts = attempts + 1;
            if(attempts > MAX_ATTEMPTS),
                error('Could not find an answer after %d attempts (%.3f, %.3f, %.3f)', MAX_ATTEMPTS, n(1),n(2),n(3) );
            end
            % pick a new y near the last and get z
            y = ( rand(1) * 0.5 * l) + v1(2);
            randnum = rand(1);
            if randnum < 1.0/3,
                pm = 1;
            elseif randnum < 2.0/3,
                pm = -1;
            else
                pm = 0;
            end
            
%             r_l = pm * (rand(1)/10) * l;
            l2 = lengths((i+1)/2);
            
            x = findX( n, v1, y, l2 );
            z = (d - n(2) * y - n(1) * x) / n(3);
            
%             z = make_vz( y, n(1),n(2),n(3), v1(1), v1(2), v1(3), d, l2 );
            if iscomplex(z),
               % disp('Z is complex.');
                continue;
            end
%             x = sqrt( -(y - v1(2))^2 - (z - v1(3))^2 + l2^2 ) + v1(1);
%             if iscomplex(x),
%                % disp('X is complex.');
%                 continue;
%             end

            % Check to see which root to use by plugging it in and checking
            % l against dist (v1, v2)
            v2 = [ x ; y ; z ];
            dist = vector_dist( v1,v2 );
            done = 1;
        end
        coords(:,i+1) = v2;
    end
    
    function X2 = findX( n, v1, y, l )
        X2 = (-(n(1) * n(2) * y) + (n(1) * d) + (v1(1) * n(3) ^ 2) - (v1(3) * n(3) * n(1)) + sqrt(-(n(3) ^ 2 * (d ^ 2 + n(3) ^ 2 * v1(2) ^ 2 + n(2) ^ 2 * y ^ 2 - 2 * n(3) ^ 2 * v1(2) * y - 2 * v1(3) * n(3) * d + n(1) ^ 2 * v1(2) ^ 2 - n(1) ^ 2 * l ^ 2 + n(1) ^ 2 * v1(1) ^ 2 + n(1) ^ 2 * y ^ 2 + 2 * n(1) * n(2) * y * v1(1) - 2 * n(1) * d * v1(1) + 2 * v1(1) * n(3) * v1(3) * n(1) + 2 * v1(3) * n(3) * n(2) * y - 2 * d * n(2) * y - 2 * n(1) ^ 2 * v1(2) * y + n(3) ^ 2 * y ^ 2 + n(3) ^ 2 * v1(3) ^ 2 - n(3) ^ 2 * l ^ 2)))) / (n(3) ^ 2 + n(1) ^ 2);
    end
end