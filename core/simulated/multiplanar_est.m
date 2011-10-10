im_coords = image_coords_from_rw_and_plane(coords);
Tx = -min(im_coords(1,:));
imc2(1,:) = im_coords(1,:)+Tx;
imc2(2,:) = abs(im_coords(2,:));
Sx = 720/max(imc2(1,:));
Sy = 540 /max(imc2(2,:));
imc(1,:) = round(imc2(1,:).*Sx);
imc(2,:) = round(Sy.*imc2(2,:));
im1 = zeros(fliplr(max(imc,[],2)'));

NUM_RUNS        = 1000;
NUM_ATTEMPTS    = 10;

all_im_ids      =  cell( NUM_RUNS, 1 );
all_x0s         =  cell( NUM_RUNS, 1 );
all_xiters      =  cell( NUM_RUNS, 1 );
all_failReasons =  cell( NUM_RUNS, 1 );
all_passes      =  cell( NUM_RUNS, 1 );
meanXs          =  cell( NUM_RUNS, 1 );
gbds            =  cell( NUM_RUNS, 1 );
runSuccess      = zeros( NUM_RUNS, 1 );


% Create GT stuff
Ch =  coords;
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
    [fR, x0s, xiters,p] = runWithErrors_sim( im_coords, ids, im1, NUM_ATTEMPTS, i );
    
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
finalSet = xm( sum(fR_mat(:,[1:4]),2 ) == 0,: );
if isempty(finalSet),
    error('Nothing came of this. Boo, hiss, etc');
end

[klbl,kcntr] = kmeans( finalSet,2 )
pause
WINSIZE = 32;
tracklet_px = cell(size(im1,1),size(im1,2));

% Preprocess tracklet pixel locations
for i=1:2:length(im_coords),
    [xs,ys] = bresenham( im_coords(1,i), im_coords(2,i), ...
                         im_coords(1,i+1),im_coords(2,i+1) );
                     
    for j=1:length(xs), 
        if xs(j) < 1 || ys(j) < 1 || xs(j) > size(im1,2) || ys(j) > size(im1,1),
%             [xs(j),ys(j)]
            continue;
        end
        tracklet_px{ys(j),xs(j)} = unique([tracklet_px{ys(j),xs(j)}, i]);
    end
end

figure;
imagesc(im1);
hold on;
labels = zeros(size(im1,1),size(im1,2));
for x = WINSIZE/2+1:size(im1,2)-WINSIZE/2,
    for y = WINSIZE/2+1:size(im1,1)-WINSIZE/2,
        winstart = [y,x]-WINSIZE/2;
        winend   = [y,x]+WINSIZE/2;
        % Get the tracklet idxs that pass through window
        CHOSENPX = tracklet_px(winstart(1):winend(1),winstart(2):winend(2));
        CHOSENPX_COL = reshape(CHOSENPX,numel(CHOSENPX),1);
        VECTORS = unique([CHOSENPX_COL{:}]);
        
        if length(VECTORS) >= 1,
            % For each centre, find sum squared error for vectors
            sumerr = zeros(size(kcntr,1),1);
            for k=1:size(kcntr,1),
                ls = zeros(length(VECTORS),1);
                for i=1:length(VECTORS),
                    p = im_coords(:, sort([VECTORS(i), VECTORS(i)+1]));
                    ls(i) = dist_eqn(kcntr(k,:),p) + 1;
                end
                sumerr(k) = std(ls);
            end
            % Now pick cluster with minimum err
            [~,labels(y,x)] = min(sumerr);
        end
    end
end
imshow(labels./size(kcntr,1));
imsc1=imagesc(im1);
alpha(imsc1,0.5)
drawcoords(im_coords,'',0,'g')