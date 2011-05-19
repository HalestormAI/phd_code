function fld_full = saveExpData( figHandles )
    fld = strcat('clusteringexps/',getTodaysFolder( ) );
    
    a        = dir(strcat('./',fld,'/run*'));
    next_id  = size(a([a.isdir] == 1),1) + 1;
    fld_full = sprintf('./%s/run%d', fld, next_id )
    mkdir( fld_full );
    
    fns = fieldnames(figHandles);
    for f=fns',
        saveas( figHandles.(char(f)), strcat(fld_full,'/',char(f),'.fig') );
    end
end