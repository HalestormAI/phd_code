function vary_l_test_script( )
%VARY_D_TEST_SCRIPT Summary of this function goes here
%   Detailed explanation goes here


l = [0.175;1.75;17.5;175;1750;17500];

s = (l .* 2) ./ 5000;


for i=1:size(l),
    iter_vary_l( l(i), 5000, 0, l(i)*2, s(i) );
end

end

