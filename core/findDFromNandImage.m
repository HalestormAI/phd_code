function [d, err, ds] = findDFromNandImage( N, im_coords )

ds = zeros( size(im_coords,2)/2, 2 );

num = 1;

x = im_coords(1,:);
y = im_coords(2,:);

for i=1:2:size(im_coords,2),
    j = i + 1;
    gamma_i = x(i) * N(1) + y(i) * N(2) + N(3);
    gamma_j = x(j) * N(1) + y(j) * N(2) + N(3);
    
    
    p1 = ( (x(i) / gamma_i) - (x(j) / gamma_j) )^2;
    p2 = ( (y(i) / gamma_i) - (y(j) / gamma_j) )^2;
    p3 = ( (1 / gamma_i) - (1 / gamma_j) )^2;
    
    d_sq = 1 / ( p1 + p2 + p3 );
    
    ds(num,:) = [ sqrt(d_sq), -sqrt(d_sq) ];
    num = num + 1;
end

d = mean( ds,1 );
err = std( ds, 0, 1 );