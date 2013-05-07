function data = load_data_pieces( name_tpl, num_data, orientations, imtraj )

    data.angleErrors        = cell( num_data, 1 );
    data.angleErrors_2      = cell( num_data, 1 );
    data.errors             = cell( num_data, 1 );
    data.fullerrors         = cell( num_data, 1 );
    data.params             = cell( num_data, 1 );
    data.rectificationError = cell( num_data, 1 );
    
    for i=1:num_data
        d = load(sprintf( name_tpl, i ));
        
        data.angleErrors{i} = cell2mat( d.iter_angleErrors' );
        data.errors{i} = cell2mat( d.iter_errors' );
        data.fullerrors{i} = d.iter_fullerrors';
        data.params{i} = cell2mat( d.iter_params' );
        
        
        data.angleErrors_2{i} = absoluteErrors( orientations, data.params{i} );
        data.rectificationError{i} = rectificationErrors( imtraj(1,:), orientations, data.params{i} );
    end
    
    function err = absoluteErrors( orientations, params )
        abserr = abs(orientations-params(:,1:2));
        err = min(abs(abserr),abs(90-abserr));
    end

    function err = rectificationErrors( imtraj, orientations, params )
        % rectify each using gt and est
        scales = [100,0.0014];
        
        err = Inf.*ones(length(orientations),1);
        raw_err = Inf.*ones(length(orientations),length(imtraj{1}));
        
        for j=1:length(orientations)
            orientation = orientations(j,:);
            est = params(j,:);
            rect_gt  = cellfun(@(x) backproj_c( orientation(1),orientation(2), ...
                                                scales(1),scales(2), x ...
                                              ),imtraj{j}, 'un', 0);
            rect_est = cellfun(@(x) backproj_c( est(1),est(2), ...
                                                scales(1),est(3), x ...
                                              ),imtraj{j}, 'un', 0);
                                          
            for t=1:length(rect_est)                     
                gt_l  = vector_dist( rect_gt{t} );
                est_l = vector_dist( rect_est{t} );

                gt_sprd  = std(gt_l)./mean(gt_l);
                est_sprd = std(est_l)./mean(est_l);

%                 raw_err(j,t) = abs(gt_sprd - est_sprd);
                raw_err(j,t) = mean(abs(gt_l./mean(gt_l) - est_l./mean(est_l)));
            end
            
            err(j) = mean(raw_err(j,:));
            
%             
%             if( i== 11 && j== 10 )
%                 figure;
%                 subplot(1,2,1);
%                 drawtraj(rect_gt,'',0);
%                 subplot(1,2,2);
%                 drawtraj(rect_est,'',0,'r');
%             end
        end
    end
end