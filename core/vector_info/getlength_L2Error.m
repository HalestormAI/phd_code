function [ error, l_av ] = getlength_L2Error( noisy )
    l_est = vector_dist( noisy(:,1:2:end), noisy(:,2:2:end) );
    l_av = mean(l_est);
    error = sum( (l_av - l_est).^2 ) / length(noisy);
end