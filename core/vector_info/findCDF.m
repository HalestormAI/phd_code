function mycdf = findCDF( vals )

    % Normalise values between [0...1]
    vals = normaliseSpeeds(vals);

    % Find CDF
    [ mycdf_f mycdf_x ] = ecdf( vals, 'Function', 'cdf' );
    mycdf = [mycdf_x,mycdf_f];

    % Remove duplicate xs for KSTEST
    [dummy,u_ix] = unique(mycdf_x);
    mycdf = mycdf(u_ix,: );
    
end