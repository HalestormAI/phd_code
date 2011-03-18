function [levels,errors,fnum] = plotOffsetAgainstAccuracy( ) 

    % Make World/Image Points
    [N_orig, C, C_im] = make_test_data( 120, 5000, 100, 0.00005, 100 );
    
    [c_est, ~ ] = iterate_to_gp( C_im );
    
    range = 0:0.05:100;
    original_error = getlength_L2Error( c_est );
    fnum = 0;
    errors = zeros(size(range,2),1);
    levels = zeros(size(range,2),1);
    C_offset = zeros( size( C ) );
    num = 1;
    h = waitbar(0,'Starting...', 'Name', sprintf('%d iterations', size(range,2)));
    for noise = range,

        waitbar(num / size(range,2), h, sprintf('Running Iteration: %d (%d%%)',num, round((num / size(range,2)) * 100)))
        
        noise_dist = normrnd( 100, noise, 1, size( C,2 )/2 );
        
        % Add random offset to pairs of points
        num2 = 1;
        for i=1:2:size( C,2 ),            
            randnum = rand(1);
            if randnum < 0.5,
                noise_pm = noise_dist(num2);
            else
                noise_pm = noise_dist(num2) .* -1;
            end
            
            C_offset(:,i:i+1) = bsxfun(@plus, C(:,i:i+1), (noise_pm .* N_orig) ) ;
            num2 = num2 + 1;
        end
        C_im_offset = image_coords_from_rw_and_plane( C_offset );
        
        try
            [ C_est_noisy, P_est_noisy ] = iterate_to_gp( C_im_offset );
            errors(num) = getlength_L2Error( C_est_noisy );
            levels(num) = noise;
            num = num + 1;      
        catch exception
            %fprintf('Failed to compute at noise: %f\n', noise);
            %disp( exception.message );
            fnum = fnum + 1;
        end
      %  num = num + 1;        
    end
    fnum
    errors(num+1:end) = [ ];
    levels(num+1:end) = [ ];
    e_av = median(errors);
    delete(h);
    figure,    
    scatter( levels, errors );
    hold on
    plot( [0 max(levels)], [e_av e_av], '-r' );
    xlabel('Standard deviation of normal noise distribution');
    ylabel('L2 Error in l');
end