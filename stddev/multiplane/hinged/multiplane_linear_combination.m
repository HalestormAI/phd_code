function [N, D] = multiplane_linear_combination( planes, gamma, P )

    N = gamma*planes(:,1) + (1-gamma)*planes(:,2);
    N = N./norm(N);
    if nargin >= 3
        D = N' * P(:,1);
    elseif nargout > 1
        error('To obtain D, please give a point on the plane');
    end

end