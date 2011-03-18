function [N_orig,C,levels,errors,fails,planes,angles,coords,n_coords,noisy_images, used_coords, badd, notunit] = plotNoiseAgainstAccuracy( ) 

    MAX_ATTEMPTS = 20;
    NUM_RANDOMS = 3;
    
    % Make World/Image Points
    [N_orig, C, C_im] = make_test_data( 20, 8, 1, 10, 100 );
    
    num = 1;
    
    im_ls = zeros(size(C_im,2)/2,1);
    for i=1:2:size(C_im,2),
        im_ls(num) = vector_dist(C_im(:,1), C_im(:,2));
        num = num + 1;
    end
    %im_sz = abs(max(max(C_im)))
    
    im_sz = mean(im_ls);
    
    range = 0:0.0008:0.2;
    
    errors = zeros(size(range,2),1);
    levels = zeros(size(range,2),1);
    planes = zeros(size(range,2),4);
    fails = zeros(size(range,2),1);
    used_coords = zeros(size(range,2),NUM_RANDOMS*2);
    angles = zeros(size(range,2),1);
    fitsdata = zeros(size(range,2),1);
    notunit = zeros(size(range,2),1);
    badd = zeros(size(range,2),1);
    coords = zeros(3,100,size(range,2));
    n_coords = zeros(3,100,size(range,2));
    noisy_images = zeros(2,100,size(range,2));
    fnum = 1;
    num = 1;
    h = waitbar(0,'Starting...', 'Name', sprintf('%d iterations', size(range,2)));
    
    % Create x0
    n = normalFromAngle( deg2rad(45), deg2rad(5) );
    %n = [0, sin(deg2rad(120)), cos(deg2rad(120)) ];      % Create a normal
    n0 = n ./ norm(n);

    x0 = [ 10, n0' ];
    
    for noise = range,
        coords(:,:,num) = C;

        waitbar(num / size(range,2), h, sprintf('Running Iteration: %d (%d%%)',num, round((num / size(range,2)) * 100)));
        [ C_im_noisy, somevarthatidontwant ] = add_coord_noise(C_im, noise, im_sz, 1);
        noisy_images(:,:,num) = C_im_noisy;
        thisFailed = 1;
        attemptNum = 1;
        
        while thisFailed == 1 && attemptNum < MAX_ATTEMPTS,
            try
                validn = 0; validd = 0;
                fixit_attempts = 0;
                while (~validn || ~validd ) && fixit_attempts < 5,
                    
                    [ C_est_noisy, P_est_noisy, cids ] = iterate_to_gp( C_im_noisy, x0, NUM_RANDOMS,'MONTECARLO' );
                    n_coords(:,:,num) = C_est_noisy;

                    used_coords(num,:) = cids;
                    errors(num) = getlength_L2Error( C_est_noisy );
                    levels(num) = noise ;

                    [validn, validd] = checkPlaneValidity( P_est_noisy );
                    fixit_attempts = fixit_attempts + 1;
                    if ~validn,
                        notunit(num) = 1;
                        fprintf('Invalid n detected: %d.\n', fixit_attempts);
                    end
                end
                if ~validn,
                    notunit(num) = 1;
               %     disp('Invalid n detected.');
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
                rw_1     = find_real_world_points( C_im_noisy, rw_plane );
                
                % And using estimated n
                im_plane = struct('d',P_est_norm(1),'n',P_est_norm(2:4));
                im_1     = find_real_world_points( C_im_noisy, im_plane );
                
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
                end
                
                angles(num) = angle;
                thisFailed = 0;
            catch exception
                if(strcmp(exception.message,'cdffail') == 1),
                    error('failsauce');
                elseif strcmp( exception.message,'Subscripted assignment dimension mismatch.') || strcmp( exception.message,'Index exceeds matrix dimensions.'),
                        rethrow( exception) 
                end
                fnum = fnum + 1;
                attemptNum = attemptNum + 1;
                if attemptNum == MAX_ATTEMPTS,
                    fprintf('Failed to compute at noise: %f: |%s| (%d attempts)\n', num, exception.message, attemptNum);
                end
                fails(num) = 1;
            end
        end
        num = num + 1;
    end
    delete(h)
    
   % levels2 = levels .^ 2;
    % Find all errors greater than 100*median and make fail
    morefails = find( errors > median(errors(find(fails==0))) * 100 )
    
    fails(morefails) = 1;
    
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
 %   d_err = abs(bsxfun(@minus, planes(fails == 0,1), 50 ));
    
    figure,    
    %scatter( levels(bad_idx == 1),     errors(bad_idx == 1), '*r' );
    scatter( levels(bad_idx == 1),    errors(bad_idx == 1), '+k' );
    hold on;
    scatter( levels(badn_idx == 1),    errors(badn_idx == 1), 'oc' );
    scatter( levels(badd_idx == 1),    errors(badd_idx == 1), 'ob' );
    scatter( levels(good_idx == 1),    errors(good_idx == 1), '*', 'MarkerFaceColor', [0,0.5,0.02], 'MarkerEdgeColor', [0,0.5,0.02] );
    scatter( levels(correct_idx == 1), errors(correct_idx == 1), 'og' ); 
    scatter( levels(wrong_idx   == 1), errors(wrong_idx   == 1), 'or' ); 
    legend('Infeasible Results','Infeasible \bf{n}', 'Infeasible d', 'Feasible Results', 'Speed Dist. Matches GT', 'Speed Dist. doesn''t Match GT');
    xlabel('SD of noise distribution as proportion of averaged image l')
    ylabel('L2 Error in l');
    title('Noise against L2 error for type-3 noise');
    figure,    
    scatter( levels(bad_idx == 1),    angles(bad_idx == 1), '+k' );
    hold on;
    scatter( levels(badn_idx == 1),    angles(badn_idx == 1), 'oc' );
    scatter( levels(badd_idx == 1),    angles(badd_idx == 1), 'ob' );
    scatter( levels(good_idx == 1),    angles(good_idx == 1), '*', 'MarkerFaceColor', [0,0.5,0.02], 'MarkerEdgeColor', [0,0.5,0.02] );
    scatter( levels(correct_idx == 1), angles(correct_idx == 1), 'og' ); 
    scatter( levels(wrong_idx   == 1), angles(wrong_idx   == 1), 'or' ); 
    legend('Infeasible Results','Infeasible \bf{n}', 'Infeasible d', 'Feasible Results', 'Speed Dist. Matches GT', 'Speed Dist. doesn''t Match GT');
    xlabel('SD of noise distribution as proportion of averaged image l')
    ylabel('Angle between actual n and estimated n (degrees).');
    title('Noise against angle error for type-3 noise');
%     scatter( winlevels(filtered_notunit == 1), winangles(filtered_notunit == 1), 'oy' );
%     hold on;
%     scatter( winlevels(filtered_badd == 1), winangles(filtered_badd == 1), 'ob' );
%     scatter( winlevels(ok_ids), winangles(ok_ids), '*g' );
%     scatter( winlevels(bad_ids), winangles(bad_ids), '*r' );
end