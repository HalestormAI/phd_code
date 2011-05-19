function sf = getBinHistogram( bins,x,y,NUM_DRN )

if nargin < 4,
    NUM_DRN = 8;
end

h = reshape(bins(y,x,:),1,NUM_DRN)

a = 0:360.0/NUM_DRN:359;

sf = figure,bar( a, h );
