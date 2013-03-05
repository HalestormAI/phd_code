function out = LCSS( A, B, TOL_s, TOL_t )
% Based on:
% A. Cheriyadat and R. J. Radke, "Detection Dominant Motions in Dense Crowds," 
% IEEE Journal of Special Topics in Signal Processing, 
% Special Issue on Distributed Processing in Vision Networks, 2(4):568-581, 2008

    n_a = length(A);
    n_b = length(B);

    try
    if isempty(A) || isempty(B)
        out = 0;
    elseif vector_dist(A(:,end), B(:,end)) < TOL_s && abs(n_a-n_b) < TOL_t
        out = LCSS(A(:,end-1),B(end-1),TOL_s,TOL_t);
    else
        L1 = LCSS(A(:,1:end-1),B,TOL_s,TOL_t);
        L2 = LCSS(A,B(:,1:end-1),TOL_s,TOL_t);
        out = max(L1,L2);
    end
    catch err
        A,B
        rethrow(err);
    end

end
