function date_folder = getTodaysFolder( )

date_folder = sprintf('%s',datestr(now, 'dd-mm-yy'));
if ~exist(date_folder,'dir'),
    mkdir('.',date_folder);
end