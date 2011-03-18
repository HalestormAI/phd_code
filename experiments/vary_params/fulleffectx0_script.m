for T = 1:5:60,
    for P = -45:5:45,
        for D=2:7,
            examineX0Effect_simulated( T, P, D, 0.0000000001, 0.0000000001 );
            close all
        end
    end
end
