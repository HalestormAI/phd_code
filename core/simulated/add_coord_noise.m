function [ noisy, e_av ] = add_coord_noise( coords, amount, im_sz, randomise )
%ADD_COORD_NOISE Adds a given amount of noise to coordinates
%   Amount should be percentage (in decimal form, i.e. 10% = 0.1).
%   The function then changes each coordinate's position by a maxmimum of
%   <amount>% per element.

noisy = zeros(size(coords));

if nargin < 3,
    randomise = 1;
end

e_sum = 0;

noise_levels = randn( size(coords) );

for i=1:size(coords,2),
    
    for j=1:size(coords,1),
        posorneg = (rand(1) > 0.5);
        n = amount*im_sz;
        r = 1;
        if randomise == 1,
            r = noise_levels(j,i);
            n = r*n;
        end
        e_sum = e_sum + abs(n*amount);
        if posorneg, 
            mult = -1;
        else
            mult = 1;
        end
        
        noisy(j,i) = mult*n + coords(j,i);
    end
    
end

e_av = e_sum / size(coords,2);

end

