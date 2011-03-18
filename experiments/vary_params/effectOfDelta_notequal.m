function dists = effectOfDelta( H, imc, im, desc )

%     deltas  = 0:0.0005:0.2;
    deltas  = ones(1,10).*0.01;
    dists   = zeros( 1, length(deltas) );
    fails   = zeros( 1, length(deltas) );
    planes  = cell( 1, length(deltas) );
    mups    = cell( 1, length(deltas) );
    compIds = cell( 1, length(deltas) );
    
    fld = strcat('equalvecs_exp/',getTodaysFolder( ) );
    
    a        = dir(strcat('./',fld,'/run*'));
    next_id  = size(a([a.isdir] == 1),1) + 1;
    fld_full = sprintf('./%s/run%d', fld, next_id )
    mkdir( fld_full );
    
    for i = 1:length(deltas), 
        try
            [planes{i}, mups{i}, d, compIds{i}, figHandles, fails, x0s]...
             = getEqualLengthVecs( H, imc, deltas(i), 10, im );
        
            dists(i) = d / length( compIds );
            
            fns = fieldnames(figHandles);
            itertxt = strrep(sprintf('delta_%.3f',deltas(i)), '.','_');
            fld_iter = strcat(fld_full,'/',itertxt );
            mkdir( fld_iter);
            for f=fns',
                saveas( figHandles.(char(f)), strcat(fld_iter,'/',char(f),'.fig') );
            end
            mup = mups{i};p = planes{i}; ids=compIds{i}; xs = x0s;
            save( strcat(fld_iter,'/data.mat') , 'mup','p','ids','d','fails','xs');
            
        catch err,
            if strcmp( err.identifier, 'IJH:USABLE:NOTENOUGH'),
%                 fails(i) = 1;
                fprintf('Failed when DELTA = %d (Not enough vectors)\n',deltas(i));
            elseif strcmp( err.identifier, 'IJH:CONVERGE:FAIL' ),
%                 fails(i) = -1;
                fprintf('Failed when DELTA = %d (Can''t converge)\n',deltas(i));
            else
                rethrow(err);
            end
        end
        close all
    end
    
    scatter( deltas,dists );
    xlabel('DELTA');
    ylabel('MINIMUM MEAN-ENDPOINT DISPLACEMENT OF COMPARISON VECTORS');
    
    save( strcat(fld_full,'/data.mat'), 'deltas', 'dists', ...
        'planes', 'mups', 'compIds', 'fails' );
    
end
    
    