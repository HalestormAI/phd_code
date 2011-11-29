function fld_full = saveExpData( figHandles,fld,suffix )
    if nargin < 2
        fld = strcat('clusteringexps/',getTodaysFolder( ) );
    end
    if nargin < 3
    
        a        = dir(strcat('./',fld,'/run*'));
        next_id  = size(a([a.isdir] == 1),1) + 1;
        suffix = sprintf('run%d', next_id );
    end
    fld_full = sprintf('./%s/%s',fld,suffix);
    mkdir( fld_full );
    
    fns = fieldnames(figHandles);
    for f=fns',
        saveas( figHandles.(char(f)), strcat(fld_full,'/',char(f),'.fig') );
    end
end