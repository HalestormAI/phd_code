function grid = generateFineGrid( initial, level ) 
    d = 1/norm(initial(1:3));
    n = initial(1:3).*d;
    [T,P] = anglesFromN(n);
    
    SCALE = 10^((-level)+1);
    
    %rotate 5 degrees in each direction in small increments
    thetas = (T-deg2rad(10*SCALE)):deg2rad(2*SCALE):(T+deg2rad(10*SCALE));
    psis   = (P-deg2rad(10*SCALE)):deg2rad(2*SCALE):(P+deg2rad(10*SCALE));
    alphas = ((1:0.2:10)./level).*initial(4);
    ds = (d-1*SCALE):0.5*SCALE:(d+1*SCALE);
%     length(thetas)
%     length(psis)
%     length(alphas)
%     length(ds)
    grid = zeros(length(thetas)*length(psis)*length(alphas)*length(ds),4);
%     size(grid)
    num = 1;
    for theta = thetas,
        for psi = psis,
            for alpha=alphas,
                for d = ds,
    %                 alpha = k;
                    n_0 = normalFromAngle( theta, psi, 'radians' );
                    grid(num,:) = [ (n_0./d)', alpha ];
                    num = num + 1;
                end
            end
        end
    end
end