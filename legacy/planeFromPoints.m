function [n,d] = planeFromPoints( C, NUM_POINTS, METHOD )

    if nargin < 2,
        NUM_POINTS = 4;
    end
    
    if nargin < 3,
        METHOD = 1;
    end
    
    
    if METHOD == 2
        % Pick n points
        ids = randperm(size(C,2))

        % For coeffecient matrix
        cs = [C(:,ids(1:NUM_POINTS));ones(1,NUM_POINTS)]';


        % Use singular value decomposition to get coeffs
        [~,~,V] = svd( cs );
        n = V(1:3,end);
        n = n/norm(n);
        d = V(4,end);
    elseif METHOD == 1
        % Alternative method: Cross product
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
    end
%     if confidence > 0.001
%         break
%     elseif num_attempts > 100
%         error('Could not find a confident solution');
%     end
end