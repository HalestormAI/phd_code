
    function x0 = generateNormal( im_coords )
        theta = randi(randi(60));
        psi   = randi(90)-45;
        n = normalFromAngle( theta, psi, 'degrees' );
        % find the best d for this normal so we're using something sensible
        if nargin == 1,
            d = findDFromNandImage( n, im_coords );
        else
            d = randi(8)+2;
        end
        x0 = [ d(1), n' ];
    end