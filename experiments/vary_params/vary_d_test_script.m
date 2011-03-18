function vary_d_test_script( )
%VARY_D_TEST_SCRIPT Summary of this function goes here
%   Detailed explanation goes here


d = [0.5;5;50;500;5000;50000];

s = (d .* 2) ./ 5000;


for i=1:size(d),
    iter_vary_d( d(i), 175, 0, d(i)*2, s(i) );
end

end

