function vary_l_and_d_test_script( )
%VARY_D_TEST_SCRIPT Summary of this function goes here
%   Detailed explanation goes here

d = [0.5;500;50000];
l = [0.175;175;17500];

sd = (d .* 2) ./ 5000;
sl = (l .* 2) ./ 5000;


for i=1:size(l),
    for j=1:size(d);
        iter_vary_d_l( d(j), l(i), 0, d(j)*2, 0, l(i)*2, 40 );
    end
end

end

