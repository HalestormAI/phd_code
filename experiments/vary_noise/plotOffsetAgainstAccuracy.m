function [N_orig,levels,errors,fails,planes,coords,n_coords,offset_coords,good_idx] = plotOffsetAgainstAccuracy( ) 

    % Make World/Image Points
    [N_orig, C, C_im] = make_test_data( 20, 8, 1, 10, 100 );
        
    range = 0:0.005:1;
    fnum = 0;
    errors = zeros(size(range,2),1);
    angles = zeros(size(range,2),1);
    levels = zeros(size(range,2),1);
    planes = zeros(size(range,2),4);
    fails = zeros(size(range,2),1);
    angles = zeros(size(range,2),1);
    fitsdata = zeros(size(range,2),1);
    badd = zeros(size(range,2),1);
    notunit = zeros(size(range,2),1);
    coords = zeros(3,100,size(range,2));
    n_coords = zeros(3,100,size(range,2));
    offset_coords = zeros(3,100,size(range,2));
    C_offset = zeros( size( C ) );
    num = 1;
    
    [ C_est, P_est ] = iterate_to_gp( C_im );
    
    % Create x0
    n = normalFromAngle( deg2rad(45), deg2rad(5) );
    %n = [0, sin(deg2rad(120)), cos(deg2rad(120)) ];      % Create a normal
    n0 = n ./ norm(n);
    x0 = [ 10, n0' ];
    
    MAX_ATTEMPTS = 20;
    NUM_RANDOMS = 3;
    
    
    h = waitbar(0,'Starting...', 'Name', sprintf('%d iterations', size(range,2)));
    for noise = range,
        coords(:,:,num) = C;

        waitbar(num / size(range,2), h, sprintf('Running Iteration: %d (%d%%)',num, round((num / size(range,2)) * 100)))
        
        noise_dist = normrnd( 0, noise, 1, size( C,2 )/2 );
        
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
            offset_coords(:,:,num) = C_offset;
        C_im_offset = image_coords_from_rw_and_plane( C_offset );
        
        try
            validn = 0; validd = 0;
            fixit_attempts = 0;
            while (~validn || ~validd ) && fixit_attempts < 5,

                [ C_est_noisy, P_est_noisy ] = iterate_to_gp( C_im_offset, x0, NUM_RANDOMS,'MAXDIST' );
                n_coords(:,:,num) = C_est_noisy;
                planes(num,:) = P_est_noisy;
                errors(num) = abs( getlength_L2Error( C_est_noisy ) - getlength_L2Error( C_est ));

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
            rw_1     = find_real_world_points( C_im_offset, rw_plane );

            % And using estimated n
            im_plane = struct('d',P_est_norm(1),'n',P_est_norm(2:4));
            im_1     = find_real_world_points( C_im_offset, im_plane );

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
            levels(num) = noise;
            fails(num) = 0;   
        catch exception
            fprintf('Failed to compute at noise: %f\n', noise);
            %disp( exception.message );
            fnum = fnum + 1;
            fails(num) = 1;
        end
        num = num + 1;        
    end
    fnum
    errors(num+1:end) = [ ];
    levels(num+1:end) = [ ];
    
    
    morefails = find( errors > median(errors(find(fails==0))) * 100 );
    
    fails2 = fails;
    fails(morefails) = 1;
   
    
    delete(h);
   
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
    title('Noise against L2 error for type-1 noise');
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
    title('Noise against angle error for type-1 noise');
  
    % NOW TAKE MEAN OF ALL 'GOOD' RESULTS
    planes(good_idx,:)
    mean_plane = mean(planes(good_idx,:),1)
    
    % PLOT MEAN IN N SPACE
    figure,
    scatter3(mean_plane(2),mean_plane(3),mean_plane(4),'om');
    hold on;
  %  scatter3(mean_plane(2),mean_plane(3),mean_plane(4),'*m');
    scatter3(N_orig(1),N_orig(2),N_orig(3),'og');
%    scatter3(N_orig(1),N_orig(2),N_orig(3),'*g');
    axis( [-1 1 -1 1 -1 0] );
    legend('Estimated N', 'Actual N');
    title(sprintf('Mean Estimated N with d=%.4f against known N with d=%.4f', mean_plane(1), 8 ) );
    
    % CLUSTER USING G-MEANS TO FIND THE NUMBER OF CLUSTERS
    clusters = gmeans(planes(good_idx,:));
    
    % PLOT CLUSTERS IN N SPACE
    figure,
    hold on;
    for i=1:size(clusters,1),
        scatter3(clusters(i,2),clusters(i,3),clusters(i,4),'om');
    end
    scatter3(N_orig(1),N_orig(2),N_orig(3),'og');
    axis( [-1 1 -1 1 -1 0] );
    legend('Estimated N', 'Actual N');
    title(sprintf('Mean Estimated N with d=%.4f against known N with d=%.4f', mean_plane(1), 8 ) );
    
end