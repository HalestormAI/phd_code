function [levels,total_error,global_error,init_error,angle_error,fails, est_all, numu, fitsdata] = plotType3Error_grid( )
    params = struct('d',3,'theta',32, 'psi', 17, 'alpha', -1/720 );
    [N_orig, ~, C_im] = makeCleanVectors(params.theta, ...
    params.psi, ...
    params.d, ...
    params.alpha, 100 );
    ABC = N_orig./params.d;
    myH = [ABC', params.alpha];
    mu_im = mean(speedDistFromCoords(C_im));
    
    levels =  0:0.001:0.5;
    angle_error  = zeros(1,length(levels));
    global_error =  cell(1,length(levels));
    C_im_noisy   =  cell(1,length(levels));
    init_error   =  cell(1,length(levels));
    total_error  = zeros(1,length(levels));
    fails        = zeros(1,length(levels));
    numu         =  cell(1,length(levels));
    est_all      =  cell(1,length(levels));
    
    NUM_WORKERS = matlabpool('size');
    if ~NUM_WORKERS,
        matlabpool;
    end
    fprintf('Running over %d noise levels\n\n', length(levels) );
    
    for n = 1:length(levels),
        fprintf('Level %d of %d\n', n, length(levels) );
        noise = levels(n);
        [ C_im_noisy{n}, ~ ] = add_coord_noise(C_im, noise, mu_im, 1);
        C_act_noisy = find_real_world_points( C_im_noisy{n}, iter2plane(myH));
        
%         init_error{n} = gp_iter_func( [ABC',params.alpha], C_im_noisy ).^2;
        init_error{n} = getlength_L2Error( C_act_noisy );
        
        [~,est_all{n},err] = gridEstimate( C_im_noisy{n} );
        fails(n) = err;
        if ~err
            numu{n}         = removeOutliersFromMean( est_all{n}, ABC, 0 );
            angle_error(n)  = 90-abs(90-angleError(N_orig, numu{n}(1:3)./norm(numu{n}(1:3))));
            global_error{n} = gp_iter_func( numu{n}, C_im_noisy{n} ).^2;
%             total_error(n)  = mean(abs(global_error{n} - init_error{n}));
            wc         = find_real_world_points(C_im_noisy{n}, iter2plane(numu{n}));
            total_error(n)   = abs( getlength_L2Error( wc ) - init_error{n} );
        end
    end
    
    fitsdata = zeros( length( numu ),1 );
    for i= 1:length(numu),
        if ~isempty( numu{i} )
            fitsdata(i) = ~notFit( C_im_noisy{i}, myH, iter2plane(numu{i}), 0.05 );
        else
            fitsdata(i) = -1;
        end
    end
    
    
    combined_errors = total_error;
    combined_errors( fitsdata == -1 ) = max(total_error);
    
    fitsdata = fitsdata+1;
    figure;
%     bar( levels, log10(total_error) );
    bar_h = bar( levels, log10(combined_errors)', 1, 'grouped' );
    bar_child = get(bar_h,'Children');
    set(bar_child,'EdgeColor','none');
    set(bar_child,'CData', fitsdata);
    set(gcf,'ColorMap',[ 0,0,1;1,0,0;0,0.7,0] )
    xlabel('Noise Level');
    ylabel('Log_{10}( Global Error )');
    title('Type 3 - L2 Error');
    
    figure;
    bar_h = bar( levels, deg2rad(angle_error), 1, 'grouped' );
    bar_child = get(bar_h,'Children');
    set(bar_child,'EdgeColor','none');
    set(bar_child,'CData', fitsdata);
    set(gcf,'ColorMap',[ 0,0,1;1,0,0;0,0.7,0] )
    xlabel('Noise Level');
    ylabel('Angle Error (Radians)');    
    title('Type 3 - Angle Error');
%     
%     figure;
%     bar( levels, log10(total_error) );
%     xlabel('Noise Level');
%     ylabel('Log_{10}( Global Error )');
%     title('Type 3 - L2 Error');
%     
%     figure;
%     colormap('lines');
%     scatter( levels, deg2rad(angle_error), 24, fails );
%     xlabel('Noise Level');
%     ylabel('Angle Error (radians)');
%     title('Type 3 - Angle Error');
end