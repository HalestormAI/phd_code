function taken_idx = smartSelection( imc, NUM_VECS, PROX_COEFF, im1 )


if nargin < 3,
    PROX_COEFF = 1/2;
end

rng = range( imc ,2 );

% Get midpoints
midpoints = (imc(:,1:2:size(imc,2)) + imc(:,2:2:size(imc,2))) ./ 2;
dists = squareform( pdist(midpoints') );

all_bad_idx = [];
taken_idx       = [];

for i=1:NUM_VECS,

    [available, IA] = setxor( 1:size(midpoints,2), all_bad_idx );
    
    if length(available) < 1,
        exception = MException('IJH:VECSEL:OUTOFVECS', ...
            'Ran out of vectors. Try reducing  PROX_COEFF.');
        throw(exception);
    end

    
    % pick a point at random (AV)
    pickidx = randi(length(available));
    idx1 = available(pickidx);
    % Put it in termss of midpoints (MP)
    idx1_mp = IA(pickidx);
    
    % Find points closer than rng(1)*PROX_COEFF and discount (MP)
    bad_idx = find( dists(idx1_mp,:) <= rng(1)*PROX_COEFF );
    all_bad_idx = [all_bad_idx, idx1_mp, bad_idx];
    
    % Append to taken array (IMC)
    taken_idx = sort( [taken_idx, idx1.*2, 2.*idx1-1] );
    
    % Draw it
    if nargin >= 4,
        figure;imagesc(im1);hold on;
        drawcoords( imc, '', 0, 'b' );
        circle( midpoints(:,idx1_mp), rng(1)*PROX_COEFF, 1000, 'r' );
        drawcoords( imc(:,taken_idx), '', 0, 'g' );
        axis([ 0, size( im1,2 ), 0,size( im1,1 )]);
    end
end

if nargin >= 4,
    figure,imagesc(im1);

    drawcoords( imc, '', 0, 'b' );

    for i=1:2:length(taken_idx),
        mp_idx = (taken_idx(i) + 1) ./2;
        circle( midpoints(:,mp_idx), rng(1)*PROX_COEFF, 1000, 'r' );
    end
    axis([ 0, size( im1,2 ), 0,size( im1,1 )]);
    drawcoords( imc( :,taken_idx ), '', 0, 'g' );
end