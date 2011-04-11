function x0 = generateNormal( im1 )
% Generates a 1x4 initial vector within reasonable bounds based.
%
% INPUT: 
%   im1     Input image used to calculate alpha
%
% OUTPUT:
%   x0      Initial vector: [ d(o), n_x(0), n_y(0), alpha(0) ]

    theta = randi(90);
    psi   = randi(90)-45;
    n_0 = normalFromAngle( theta, psi, 'degrees' );
    % find the best d for this normal so we're using something sensible
    d = randi(8)+2;
    alpha = 1/length(im1);
    x0 = [ d(1), n_0', alpha ];
end