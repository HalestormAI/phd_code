clear
close all
% 
% load soc_carpark1
% im1=im2;im_coords=imc;
% load seq_eth
 
% 
load students003_data

% Centralise coords
% middle = [size(im1)./2];
% middle = middle(1:2)';
% im_coords_orig = im_coords;
% im_coords = im_coords - repmat(middle,1,length(im_coords));

NUM_RUNS        = 100;
NUM_ATTEMPTS    = 100;

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

if matlabpool('size') < 1,
    matlabpool;
end

parfor i=1:NUM_RUNS,
    % Get some image vectors
    [~,~,ids] = pickIds( Ch_norm, im_coords, 0.1, im1, 4 );
    all_im_ids{i} = ids;
    
    % Perform a run of NUM_ATTEMPTS attempts
    [fR, x0s, xiters,p] = runWithErrors( im_coords, H, ids, im1, NUM_ATTEMPTS, i );
    
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

xm       = cell2mat(all_xiters)
fR_mat   = cell2mat(all_failReasons)
finalSet = xm( sum(fR_mat(:,[1:4]),2 ) == 0,: );
if isempty(finalSet),
    error('Nothing came of this. Boo, hiss, etc');
end
N        = findNormalFromH( H );
numu     = removeOutliersFromMean( finalSet, N.a, 1 );

plane = iter2plane(numu);

[dist,idx_pick,handles] = finalTry( Ch, plane, im_coords, 30 );

save alldata