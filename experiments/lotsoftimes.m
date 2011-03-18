function mup = lotsoftimes( imc, H, NUM_RUNS )

N = findNormalFromH( H );

% Run vidPointEst to get starting point
[~,planes] = videoPointEstimation( imc, N.a, 20, 3 );

x0 = removeOutliersFromMean( planes, N.a, 1 );
mup = x0;
% mups = zeros(NUM_RUNS, 4);
% for i = 1:NUM_RUNS,
%     mup = stage2( imc, x0, 0.05, 20, i );
%     mups(NUM_RUNS,:) = mup;
%     x0 = mup;
% end

%% Ground truth
Ch = H*makeHomogenous( imc );
mu_l = findLengthDist( Ch, 0 );
Ch_norm = Ch ./ mu_l;

%% Compare result
ids = finalTry( Ch_norm, mup(2:4)', imc, 50 );
