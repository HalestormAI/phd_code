function [levels,errors,fnum] = plotNotevenAgainstAccuracy( )

    % Make World/Image Points
    
    range = 0:0.05:100;
    
    errors = zeros(size(range,2),1);
    levels = zeros(size(range,2),1);
    num = 1;
    fnum = 0;
    h = waitbar(0,'Starting...', 'Name', sprintf('%d iterations', size(range,2)));
    for noise = range,

        waitbar(num / size(range,2), h, sprintf('Running Iteration: %d (%d%%)',num, round((num / size(range,2)) * 100)))
        done = 0;
        while ~done,            
            try
                [N_orig, C, C_im,C_ne,C_ne_im] = make_test_data( 45, 5000, 100, 0.05, 100, noise );
                done = 1;
            catch exception
                done = 0;
                disp( exception.message );
            end
        end
        try
            [ C_est_noisy, P_est_noisy ] = iterate_to_gp( C_ne_im );
            errors(num) = abs(getlength_L2Error(C_ne) - getlength_L2Error( C_est_noisy ));
            levels(num) = noise ;
        catch exception
            %fprintf('Failed to compute at noise: %f\n', noise);
            %disp( exception.message );
            fnum = fnum + 1;
        end
        num = num + 1;        
    end
    delete(h)
    fnum
    figure,    
    scatter( levels, errors );
    xlabel('Standard deviation of normal noise distribution');
    ylabel('L2 Error in l');
end