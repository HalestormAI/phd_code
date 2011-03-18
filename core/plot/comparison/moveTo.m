
    function C_o = moveTo( C, P )
        if nargin < 2,
            P = [0;0;0];
        end
        
        C_av = mean( C, 2 );
        
        C_o = C - repmat(C_av,1, size(C,2)) + repmat(P,1, size(C,2)) ;
    end