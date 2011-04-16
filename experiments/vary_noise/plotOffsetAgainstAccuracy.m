function [N_orig,levels,errors,fails,planes,coords,n_coords,offset_coords,good_idx, all_planes, all_failRs] = plotOffsetAgainstAccuracy( ) 

    % Make World/Image Points    
    params = struct('d',3,'theta',65, 'psi', 30, 'alpha', 1/720 );
    
    
    % Make World/Image Points
    [N_orig, C, C_im] = makeCleanVectors(params.theta, ...
                                         params.psi, ...
                                         params.d, ...
                                         params.alpha, 100 );
    myH = [params.d, N_orig', params.alpha];
        
    range = 0:0.01:1;
    errors          = zeros(size(range,2),1);
    levels          = zeros(size(range,2),1);
    planes          = zeros(size(range,2),5);
    fails           = zeros(size(range,2),1);
    angles          = zeros(size(range,2),1);
    fitsdata        = zeros(size(range,2),1);
    badd            = zeros(size(range,2),1);
    notunit         = zeros(size(range,2),1);
    coords          = zeros(3,100,size(range,2));
    n_coords        = zeros(3,100,size(range,2));
    offset_coords   = cell(size(range,2),1);
    all_planes      = cell(length(range),1);
    all_failRs      = cell(length(range),1);
    
    
    
    NUM_WORKERS = matlabpool('size');
    if ~NUM_WORKERS,
        matlabpool;
    end
    
    parfor num = 1:length(range),
        noise = range(num);
        [~,wcn] = addType1Noise( C, N_orig, noise );
        C_imn = wc2im( wcn, params.alpha );
        offset_coords{num} = wcn;

        % Pick 3 vectors
        ids_full = smartSelection(C_im, 3, 1/3);
        
        % Get 10 estimates
        [failReasons, ~, xiters] = ...
            runWithErrors(C_imn,myH,ids_full,1:720,10,0);
        
        mup        = mean(xiters(~sum(failReasons(:,1:4)),:),1)
        mup_struct = iter2plane(mup);
        wc         = find_real_world_points(C_im, mup_struct);
        
        
        all_failRs{num} = failReasons;
        all_planes{num} = xiters;
        
        n_coords(:,:,num)  = wc;       

        [validn, validd] = checkPlaneValidity( iter2plane(mup) );
        
        if ~validn,
            notunit(num) = 1;
        end
        if ~validd,
            badd(num) = 1;
        end
        
        
        angles(num)   = 90-abs(90-angleError(N_orig, mup_struct.n));
        errors(num)   = abs( getlength_L2Error( wc ) );
        levels(num)   = noise;
        planes(num,:) = mup;
        
        fitsdata(num) = ~notFit( C_im, myH, iter2plane(mup), 0.05 );
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
    xlabel('SD of noise distribution as proportion of averaged image l')
    ylabel('Angle between actual n and estimated n (degrees).');
    title('Noise against angle error for type-1 noise');    
end