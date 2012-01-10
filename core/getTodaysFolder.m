function date_folder = getTodaysFolder( DONT_CREATE )

date_folder = sprintf('%s',datestr(now, 'dd-mm-yy'));
if (nargin < 1 || ~DONT_CREATE ) && ~exist(date_folder,'dir'),
    mkdir('.',date_folder);
end