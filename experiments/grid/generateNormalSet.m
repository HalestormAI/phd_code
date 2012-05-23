function [x0s,vars] = generateNormalSet( alphas, ds, thetas, psis )
    if nargin < 1,
        alphas = [10.^(-3:.5:3)];
    end
    if nargin < 2,
    ds     = 1:10;
    end
    if nargin < 3,
        thetas = 5:15:85;
    end
    if nargin < 4,
        psis   = -60:15:60;
    end

    num = 1;


    % length(valid_thetas)*length(valid_psis)*length(valid_ds)*length(START:STEP:END);
    varl = length(thetas)*length(psis)*length(alphas)*length(ds);
    x0s = zeros(varl,4);
    vars = zeros(varl,4);
    for theta = thetas,
        for psi = psis,
            for alpha=alphas,
                for d = ds,
    %                 alpha = k;
                    n_0 = normalFromAngle( theta, psi, 'degrees' );
                    x0s(num,:) = [ (n_0./d)', alpha ];
                    vars(num,:) = [theta,psi,alpha,d];
                    num = num + 1;
                end
            end
        end
    end
    if sum(sum(abs(x0s)  == Inf)) > 0
        error('TO INFINITY AND BEYOND');
    end
end