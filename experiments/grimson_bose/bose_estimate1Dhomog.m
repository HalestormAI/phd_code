function [G,p] = bose_estimate1Dhomog( p_prime )
    
    p = linspace(min(p_prime(1,:)), max(p_prime(1,:)), length(p_prime));
    
    G = homography1d( [p_prime;ones(1,length(p))],[p;ones(1,length(p))] );

end