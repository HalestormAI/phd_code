function [N, D] = multiplane_linear_combination2( planes, lambda, P )

    if length(lambda) ~= 2
        error('Lambda should be a 1x2 or 2x1 vector');
    end

    N = lambda(1)*planes(:,1) + lambda(2)*planes(:,2);
    N = N./norm(N);
    if nargin >= 3
        D = N' * P(:,1);
    elseif nargout > 1
        error('To obtain D, please give a point on the plane');
    end

end