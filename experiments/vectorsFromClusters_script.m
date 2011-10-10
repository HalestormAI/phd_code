% find most used cluster and draw vectors from only that
blockids = find(idxs == mode(idxs));
% In the case where most common is zero activity, pick again
if  sum(centres(mode(idxs),:)) == 0,
    blockids = find(idxs == mode(idxs(idxs~=mode(idxs))) );
end
imc_clust = [];
for i=1:2:length(im_coords),
    [xs,ys] = bresenham( im_coords(1,i), im_coords(2,i), ...
                         im_coords(1,i+1),im_coords(2,i+1) );
                     
    % get block ids from xs, ys
    blocks = unique(ceil([ys,xs]./binsz),'rows');
    common = intersect(blocks, positions(blockids,:),'rows');
    if ~isempty(common)
        imc_clust = [imc_clust,im_coords(:,i),im_coords(:,i+1)];
    end
end


NUM_RUNS        = 100;
NUM_ATTEMPTS    = 20;

all_im_ids      =  cell( NUM_RUNS, 1 );
all_x0s         =  cell( NUM_RUNS, 1 );
all_xiters      =  cell( NUM_RUNS, 1 );
all_failReasons =  cell( NUM_RUNS, 1 );
all_passes      =  cell( NUM_RUNS, 1 );
meanXs          =  cell( NUM_RUNS, 1 );
gbds            =  cell( NUM_RUNS, 1 );
runSuccess      = zeros( NUM_RUNS, 1 );

% Create GT stuff
Ch = H*makeHomogenous( imc_clust );
mu_l = findLengthDist( Ch, 0 );
Ch_norm = Ch ./ mu_l;

if matlabpool('size') < 1,
    matlabpool;
end

parfor i=1:NUM_RUNS,
    % Get some image vectors
    [~,~,ids] = pickIds( Ch_norm, imc_clust, 500, im1, 4 );
    all_im_ids{i} = ids;
    
    % Perform a run of NUM_ATTEMPTS attempts
    [fR, x0s, xiters,p] = runWithErrors( imc_clust, H, ids, im1, NUM_ATTEMPTS, i );
    
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
matlabpool close

xm       = cell2mat(all_xiters)
fR_mat   = cell2mat(all_failReasons)
finalSet = xm( sum(fR_mat(:,[1:4]),2 ) == 0,: );
if isempty(finalSet),
    error('Nothing came of this. Boo, hiss, etc');
end
N               = findNormalFromH( H );
[numu,~,mnHndl] = removeOutliersFromMean( finalSet, N.a, 1 );

plane = iter2plane(numu);

[dist,idx_pick,handles] = finalTry( Ch, plane, imc_clust, 30 );
handles.convergence = mnHndl;
fldr = saveExpData(handles);
save( strcat(fldr,'data.mat'));