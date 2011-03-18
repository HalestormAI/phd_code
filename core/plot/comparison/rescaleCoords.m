
    function C_s = rescaleCoords( C_e, C_a )
        [mu_a,~,~] = findLengthDist( C_a, 0 )
%         title('actual')
        [mu_e,~,~] = findLengthDist( C_e, 0 )
%         title('est')
        k = mu_a/mu_e;

        C_s = C_e*k;
    end