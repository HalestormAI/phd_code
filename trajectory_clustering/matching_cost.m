function Q = matching_cost( A, B, TOL_e, TOL_d )
% Based on:
% A. Cheriyadat and R. J. Radke, "Detection Dominant Motions in Dense Crowds," 
% IEEE Journal of Special Topics in Signal Processing, 
% Special Issue on Distributed Processing in Vision Networks, 2(4):568-581, 2008

M = length(A);
N = length(B);

if nargin < 3
    TOL_e = 50;
end
if nargin < 4
    TOL_d = max(M,N);
end

Q = Inf*ones(M,N);

for m=1:M
    for n=1:N
        if m==1 || n==1
            Q(m,n) = 0;
        elseif sqrt( sum((A(:,m)-B(:,n)).^2) ) < TOL_e && abs(m-n) < TOL_d
            Q(m,n) = 1 + Q(m-1,n-1);
        else
            Q(m,n) = max( Q(m-1,n),Q(m,n-1) );
        end
    end
end

