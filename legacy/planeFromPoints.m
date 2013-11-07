function [n,d] = planeFromPoints( C, NUM_POINTS, METHOD )
% Calculates the plane parameters `n` and `d` from a set of points using
% one of two methods.
    if nargin < 2 || isempty(NUM_POINTS),
        NUM_POINTS = 4;
    end
    
    if nargin < 3,
        METHOD = 1;
    end
    
    
    if strcmpi(METHOD,'cross') || (isnumeric(METHOD) && METHOD == 1) % Cross product
        A = C(:,1)-C(:,2);
        B = C(:,3)-C(:,1);
        n = cross(A,B)./norm(cross(A,B));
        if n(3) > 0,
            n = n.*-1;
        end

        ds = zeros(1,NUM_POINTS);
        for i=1:NUM_POINTS,
            ds(i) = n(1)*C(1,i) + n(2)*C(2,i) + n(3)*C(3,i);
        end

        d = mean(ds);
        confidence = 1/(std(ds)/d);
    elseif strcmpi(METHOD,'svd') || (isnumeric(METHOD) && METHOD == 2) % svd
        % Pick n points
        ids = randperm(size(C,2));

        % For coeffecient matrix
        cs = [C(:,ids(1:NUM_POINTS));ones(1,NUM_POINTS)]';


        % Use singular value decomposition to get coeffs
        [~,~,V] = svd( cs );
        n = V(1:3,end);
        n = n/norm(n);
        d = V(4,end);
    else
        error('Invalid METHOD value. Should be one of ''svd'' or ''cross''');
    end
%     if confidence > 0.001
%         break
%     elseif num_attempts > 100
%         error('Could not find a confident solution');
%     end
end