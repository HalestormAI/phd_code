function [x0s,vars] = generateNormalSet_ls( alphas, ds, thetas, psis, ls )
if nargin < 1,
    alphas = [-10.^(-3:1),10.^(-3:1)];
end
if nargin < 2,
ds     = 1:10;
end
if nargin < 3,
    thetas = 5:10:85;
end
if nargin < 4,
    psis   = -60:10:60;
end
if nargin < 5,
    ls     = 0.1:0.1:10;
end

num = 1;


% length(valid_thetas)*length(valid_psis)*length(valid_ds)*length(START:STEP:END);
varl = length(thetas)*length(psis)*length(alphas)*length(ds);
x0s = zeros(varl,5);
vars = zeros(varl,5);
for theta = thetas,
    for psi = psis,
        for alpha=alphas,
            for d = ds,
                for l = ls,
%                 alpha = k;
                    n_0 = normalFromAngle( theta, psi, 'degrees' );
                    x0s(num,:) = [ (n_0./d)', alpha, l ];
                    vars(num,:) = [theta,psi,alpha,d,l];
                    num = num + 1;
                end
            end
        end
    end
end
if sum(sum(abs(x0s)  == Inf)) > 0
    error('TO INFINITY AND BEYOND');
end