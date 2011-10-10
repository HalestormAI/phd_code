function x0 = generateNormal( COEFF )
% Generates a 1x4 initial vector within reasonable bounds based.
%
% INPUT: 
%   im1     Input image used to calculate alpha
%
% OUTPUT:
%   x0      Initial vector: [ d(o), n_x(0), n_y(0), alpha(0) ]

    if nargin < 1,
            COEFF = 2;
    else
        if length(COEFF) > 1,
            error('COEFF SHOULD BE A SINGLE FLOAT');
        end
    end

    theta = randi(60);
    psi   = randi(90)-45;
    n_0 = normalFromAngle( theta, psi, 'degrees' );
    % find the best d for this normal so we're using something sensible
    d = randi(8)+2;
    alpha = -1/(randi(10)*(10^COEFF));
% alpha = -1/720;
%     alpha = 1;
%      l_0 = rand+0.5;
    x0 = [ (n_0.*d)', alpha ];
%     x0 = [ d(1), n_0', l_0, alpha ];
%     x0 = [ d(1), n_0' ];
end