function I = longest_common_subseq( A, B, Q, TOL_e, TOL_d )

    M = length(A);
    N = length(B);

    if nargin < 4
        TOL_e = 50;
    end
    if nargin < 5
        TOL_d = max(M,N);
    end

    I = [];
    m = M;
    n = N;

    while m > 1 && n > 1
        if vector_dist(A(:,m),B(:,n)) < TOL_e && abs(m-n) < TOL_d
            I = [I;[m,n]];
        elseif Q(m,n-1) >= Q(m-1,n)
            n = n-1;
        else
            m = m-1;;
        end
    end

end
