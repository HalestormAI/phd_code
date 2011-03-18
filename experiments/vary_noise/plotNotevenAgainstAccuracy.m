function [N_orig,levels,errors,fails,planes,original_error,new_error,coords,n_coords] = plotNotevenAgainstAccuracy( )

    % Make World/Image Points
    
    range = 0:0.004:1;
    
    % Create x0
    n = normalFromAngle( deg2rad(45), deg2rad(5) );
    %n = [0, sin(deg2rad(120)), cos(deg2rad(120)) ];      % Create a normal
    n0 = n ./ norm(n);
    x0 = [ 10, n0' ];
    
    MAX_ATTEMPTS = 2;
    NUM_RANDOMS = 3;
    
    
    errors = zeros(size(range,2),1);
    levels = zeros(size(range,2),1);
    planes = zeros(size(range,2),4);
    fails = zeros(size(range,2),1);
    fitsdata = zeros(size(range,2),1);
    notunit = zeros(size(range,2),1);
    badd = zeros(size(range,2),1);
    angles = zeros(size(range,2),1);
    original_error = zeros(size(range,2),1);
    new_error = zeros(size(range,2),1);
    coords = zeros(3,100,size(range,2));
    n_coords = zeros(3,100,size(range,2));
    num = 1;
    fnum = 0;
    h = waitbar(0,'Starting...', 'Name', sprintf('%d iterations', size(range,2)));
    for noise = range,

        waitbar(num / size(range,2), h, sprintf('Running Iteration: %d (%d%%)',num, round((num / size(range,2)) * 100)));
        done = 0;
            levels(num) = noise ;
        while ~done,            
            try
                [N_orig, fggf, fdgsd,C_ne,C_ne_im] = make_test_data( 20, 8, 1, 10, 100, noise );
                coords(:,:,num) = C_ne;
                original_error(num) = getlength_L2Error(C_ne);
                done = 1;
            catch exception
                done = 0;
                delete(h)
                error( exception.message );
                fails(num) = 1;
            end
        end
       thisFailed = 1;
       attemptNum = 1;
        
        while thisFailed == 1 && attemptNum < MAX_ATTEMPTS,
            try
                validn = 0; validd = 0;
                fixit_attempts = 0;
                while (~validn || ~validd ) && fixit_attempts < 5,

                    [ C_est_noisy, P_est_noisy ] = iterate_to_gp( C_ne_im, x0, NUM_RANDOMS,'MAXDIST' );
                    n_coords(:,:,num) = C_est_noisy;

                    errors(num) = abs(getlength_L2Error(C_ne) - getlength_L2Error( C_est_noisy ));
                    noise_error = getlength_L2Error(C_est_noisy);
                    new_error(num) = noise_error;
                    planes(num,:) = P_est_noisy;

                    [validn, validd] = checkPlaneValidity( P_est_noisy );
                    fixit_attempts = fixit_attempts + 1;
                    if ~validn,
                        notunit(num) = 1;
                        fprintf('Invalid n detected: %d.\n', fixit_attempts);
                    end
                end

                if ~validn,
                    notunit(num) = 1;
                    disp('Invalid n detected.');
                end
                if ~validd,
                    badd(num) = 1;
                end
                
                
                P_est_norm = [P_est_noisy(1), P_est_noisy(2:4) ./ norm(P_est_noisy(2:4))];
                planes(num,:) = P_est_norm;
                angle = rad2deg( acos(dot(N_orig',P_est_norm(2:4)) / ( norm(N_orig')*norm(P_est_norm(2:4)) ) ) );
                if iscomplex( angle ),
                    angle
                    error('IMAGINARY :(');
                end
                
                % Need to find 3D points using N_orig
                rw_plane = struct('d',2,'n',N_orig);
                rw_1     = find_real_world_points( C_ne_im, rw_plane );
                
                % And using estimated n
                im_plane = struct('d',P_est_norm(1),'n',P_est_norm(2:4));
                im_1     = find_real_world_points( C_ne_im, im_plane );
                
                % Now get speed distributions from both rw and im coords
                rw_spds  = speedDistFromCoords( rw_1 );
                im_spds  = speedDistFromCoords( im_1 );
                
                try
                    % Take CDF from rw speeds
                    mycdf = findCDF( rw_spds );
                    
                    % Compare normalised im speeds to CDF using kstest
                    fitsdata(num) = kstest( normaliseSpeeds(im_spds), mycdf, 0.00001 ) == 0;
                catch exception
                   disp( exception.message);
                   error('cdffail')
                   break;
                end
                angles(num) = angle;
                
                
                fails(num) = 0;
                thisFailed = 0;
            catch exception
                fnum = fnum + 1;
                attemptNum = attemptNum + 1;
                if attemptNum >= MAX_ATTEMPTS,
                    fprintf('Failed to compute at noise: %f: %s (%d attempts)\n', num, exception.message, attemptNum);
                end
                fails(num) = 1;
            end
        end
        num = num + 1;     
    end
    delete(h)
    
    % Find all errors greater than 100*median and make fail
    morefails = find( errors > median(errors(find(fails==0))) * 100 );
    
%     fails2 = fails;
    fails(morefails) = 1;
%     
%     winlevels = levels( fails == 0 );
%     winerrors = errors( fails == 0 );
%     winangles = 90-abs(90-angles(fails == 0));

  % FOR DRAWING BAD D
  
    % FOR DRAWING BAD D
    badd_idx = and( (1-fails) , badd );
    % FOR DRAWING BAD N
    badn_idx = and( (1-fails) , notunit );
    % FOR DRAWING GOOD
    good_idx = and( and( (1-fails) , 1-badd ), and( (1-fails) , 1-notunit ) );
    % FOR DRAWING BAD
    bad_idx  = or( and( (1-fails) , badd ), and( (1-fails) , notunit ) );
    
    % FOR CORRECT & GOOD
    correct_idx = and( good_idx, fitsdata );
    wrong_idx   = and( good_idx, 1-fitsdata );
    
    figure, 
    
    scatter( levels(bad_idx == 1),    errors(bad_idx == 1), '+k' );
    hold on;
    scatter( levels(badn_idx == 1),    errors(badn_idx == 1), 'oc' );
    scatter( levels(badd_idx == 1),    errors(badd_idx == 1), 'ob' );
    scatter( levels(good_idx == 1),    errors(good_idx == 1), '*', 'MarkerFaceColor', [0,0.5,0.02], 'MarkerEdgeColor', [0,0.5,0.02] );
    scatter( levels(correct_idx == 1), errors(correct_idx == 1), 'og' ); 
    scatter( levels(wrong_idx   == 1), errors(wrong_idx   == 1), 'or' ); 
    legend('Infeasible Results','Infeasible \bf{n}', 'Infeasible d', 'Feasible Results', 'Speed Dist. Matches GT', 'Speed Dist. doesn''t Match GT');
    xlabel('Standard deviation of normal noise distribution')
    ylabel('L2 Error in l');
    title('Noise against L2 error for type-2 noise');
    figure,        
    scatter( levels(bad_idx == 1),    angles(bad_idx == 1), '+k' );
    hold on;
    scatter( levels(badn_idx == 1),    angles(badn_idx == 1), 'oc' );
    scatter( levels(badd_idx == 1),    angles(badd_idx == 1), 'ob' );
    scatter( levels(good_idx == 1),    angles(good_idx == 1), '*', 'MarkerFaceColor', [0,0.5,0.02], 'MarkerEdgeColor', [0,0.5,0.02] );
    scatter( levels(correct_idx == 1), angles(correct_idx == 1), 'og' ); 
    scatter( levels(wrong_idx   == 1), angles(wrong_idx   == 1), 'or' ); 
    legend('Infeasible Results','Infeasible \bf{n}', 'Infeasible d', 'Feasible Results', 'Speed Dist. Matches GT', 'Speed Dist. doesn''t Match GT');
    xlabel('Standard deviation of normal noise distribution')
    ylabel('Angle between actual n and estimated n (degrees).');
    title('Noise against angle error for type-2 noise');
    
%     fnum
%     figure,    
%     scatter( winlevels(fitsdata(fails == 0) == 0), winerrors(fitsdata(fails == 0) == 0), '*r' );
%     hold on;
%     scatter( winlevels(notunit(fails == 0) == 1), winerrors(notunit(fails == 0) == 1), '*b' );
%     scatter( winlevels(badd(fails == 0) == 1), winerrors(badd(fails == 0) == 1), 'om' );
%     scatter( winlevels(fitsdata(fails == 0) == 1), winerrors(fitsdata(fails == 0) == 1), '*g' );
%     xlabel('Standard deviation of normal noise distribution');
%     ylabel('L2 Error in l'); 
%     figure,    
%     scatter( winlevels(fitsdata(fails == 0) == 0), winangles(fitsdata(fails == 0) == 0), '*r' );
%     hold on;
%     scatter( winlevels(notunit(fails == 0) == 1), winangles(notunit(fails == 0) == 1), '*b' );
%     scatter( winlevels(badd(fails == 0) == 1), winangles(badd(fails == 0) == 1), 'om' );
%     scatter( winlevels(fitsdata(fails == 0) == 1), winangles(fitsdata(fails == 0) == 1), '*g' );
%     xlabel('Standard deviation of normal noise distribution');
%     ylabel('Angle between actual n and estimated n (degrees).');
   
end