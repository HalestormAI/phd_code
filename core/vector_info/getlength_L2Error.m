function [ error, l_av ] = getlength_L2Error( noisy )

    l_est = zeros(1, size(noisy,2)/2 );    
    num = 1;
    for i=1:2:size(noisy,2),
        l_est(num) = vector_dist( noisy(:,i), noisy(:,i+1) );
        num = num + 1;
    end
    %l_est
    l_av = mean( l_est );
    squared_diff = ( l_av - l_est ) .^ 2;
    error = sum( squared_diff ) / size(noisy,2);
    

end