function [N_orig,levels,errors,fails,planes,base_error,offset_coords,all_failRs,all_planes, myH, params] = plotNotevenAgainstAccuracy( )

    % Make World/Image Points    
    
    
    % Make World/Image Points
        
    range = 0:0.02:1;
    
    errors          = zeros(size(range,2),1);
    levels          = zeros(size(range,2),1);
    planes          = zeros(size(range,2),5);
    fails           = zeros(size(range,2),1);
    angles          = zeros(size(range,2),1);
    fitsdata        = zeros(size(range,2),1);
    badd            = zeros(size(range,2),1);
    notunit         = zeros(size(range,2),1);
    base_error      = zeros(size(range,2),1);
    offset_coords   =  cell(length(range),1);
    all_planes      =  cell(length(range),1);
    all_failRs      =  cell(length(range),1);
    
    
    NUM_WORKERS = matlabpool('size');
    if ~NUM_WORKERS,
        matlabpool;
    end
    params = struct('d',3,'theta',65, 'psi', 30, 'alpha', 1/720 );
    N_orig = normalFromAngle( params.theta, params.psi );                                
    myH = [params.d, N_orig', params.alpha];
    
    parfor num = 1:length(range),
        noise = range(num);
        done = 0;
        while ~done;
            try
                [~, C, C_im] = makeNoisyVectors(params.theta, ...
                                                params.psi, ...
                                                params.d, ...
                                                params.alpha, ...
                                                [0 noise 0], 10 ); %#ok<PFBNS>
                                               % Make iter vector for GT 

                offset_coords{num}  = C;
                base_error(num) = getlength_L2Error( C );
                disp(base_error(num));

                % Pick 3 vectors
                ids_full = smartSelection(C_im, 3, 1/4);

                % Get 10 estimates
                [failReasons, ~, xiters] = ...
                    runWithErrors(C_im,myH,ids_full,1:720,20,0);

                fprintf('Iteration %d\n',num);
                
                mup        = mean(xiters(~sum(failReasons(:,1:4)),:),1);
                mup_struct = iter2plane(mup);
                wc         = find_real_world_points(C_im, mup_struct);


                all_failRs{num} = failReasons;
                all_planes{num} = xiters;

                [validn, validd] = checkPlaneValidity( iter2plane(mup) );

                if ~validn,
                    notunit(num) = 1;
                end
                if ~validd,
                    badd(num) = 1;
                end


                angles(num)   = 90-abs(90-angleError(N_orig, mup_struct.n));
                errors(num)   = abs( base_error(num) - getlength_L2Error( wc ) );
                
                muwc    = findLengthDist(wc);
                wc2     = wc ./ muwc;
                wc_dist = speedDistFromCoords( wc2 );
                gt_dist = speedDistFromCoords(  C );
                
                dists = (gt_dist - wc_dist).^2;
                errors(num) = sum(dists)/(length(C)/2);
                levels(num)   = noise;
                planes(num,:) = mup;

                fitsdata(num) = ~notFit( C_im, myH, iter2plane(mup), 0.05 );
                done = 1;
            catch err,
                disp(err.identifier);
            end
        end
     
    end
    
    morefails = find( errors > median(errors(find(fails==0))) * 100 );
    
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
    xlabel('SD of noise distribution as proportion of averaged image l')
    ylabel('Angle between actual n and estimated n (degrees).');
    title('Noise against angle error for type-2 noise');    
end