clear
close all

load soc_carpark1
im1=im2;im_coords=imc;

NUM_RUNS        = 100;
NUM_ATTEMPTS    = 500;
all_im_ids      =  cell( NUM_RUNS, 1 );
all_x0s         =  cell( NUM_RUNS, 1 );
all_xiters      =  cell( NUM_RUNS, 1 );
all_failReasons =  cell( NUM_RUNS, 1 );
all_passes      =  cell( NUM_RUNS, 1 );
meanXs          =  cell( NUM_RUNS, 1 );
gbds            =  cell( NUM_RUNS, 1 );
runSuccess      = zeros( NUM_RUNS, 1 );


% Create GT stuff
Ch = H*makeHomogenous( im_coords );
mu_l = findLengthDist( Ch, 0 );
Ch_norm = Ch ./ mu_l;

parfor i=1:NUM_RUNS,
    % Get some image vectors
    [~,~,ids] = pickIds( Ch_norm, im_coords, 500 );
    all_im_ids{i} = ids;
    
    % Perform a run of NUM_ATTEMPTS attempts
    [fR, x0s, xiters,p] = runWithErrors( im_coords, H, ids, NUM_ATTEMPTS, i );
    
    all_x0s{i}         = x0s;
    all_xiters{i}      = xiters;
    all_failReasons{i} = fR;
    all_passes{i}      = p;
    
    % Try to get mean of good results, if none, then do a new run.
    try
        [~,~,gbd, x_mn] = getFailStats( fR, xiters );
        gbds{i}   = gbd;
        meanXs{i} = x_mn;
        runSuccess(i) = 1;
     catch err,
        if strcmp( err.identifier, 'IJH:FAILS:EMPTY'),
            runSuccess(i) = 0;
            continue;
        else
            rethrow(err);
        end
    end
end

xm       = cell2mat(all_xiters);
fR_mat   = cell2mat(all_failReasons);
finalSet = xm( sum(fR_mat(:,[1,2,4,5]),2 ) == 0,: );
N        = findNormalFromH( H );
numu     = removeOutliersFromMean( finalSet, N.a, 1 );
[dist,idx_pick,handles] = finalTry( Ch, numu(2:4)', im_coords, 30 );