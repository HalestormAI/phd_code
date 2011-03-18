function [n_o,c_o,l,e,f,p,a,c,n_c,c_i_n,i_used] = runTests( n_o,c_o,l,e,f,p,a,c,n_c,c_i_n,i_used )

if nargin < 11,
    [n_o,c_o,l,e,f,p,a,c,n_c,c_i_n,i_used] = plotNoiseAgainstAccuracy( );
end

passes = find(f==0)

[maxnum,mai] = max(a(passes))

p_l = l(f==0)

worst = find(l == p_l(mai));


drawPlanes( 50, n_o, p, c, n_c, l, worst );

highlightDrawnCoords( c, c_i_n, i_used, worst )