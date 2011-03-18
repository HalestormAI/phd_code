close all;

fld      = getTodaysFolder( );
fld_full = sprintf('%s/covar_outlierremoval', fld);
mkdir( fld_full );

max_iters = 100;

for i=1:max_iters,
    % Make a random plane and get some estimates
    t     = randi(60);
    p     = randi(90)-45;
    d     = randi(8)+2;
    noise = [ rand(1)/2, rand(1)/2, rand(1)*0.2 ];
    
    myfile = fopen(sprintf('%s/experiments.txt',fld_full),'a');
    fprintf(myfile, '%d) [theta=%d,psi=%d,d=%d,iters=%d,num_vecs=%d. Noise: Type 1 - %.3f, Type 2 - %.3f, Type 3 - %.3f\n', ...
        i, t, p,d, 100, 3,noise(1),noise(2),noise(3));
    
    [~,planes,n] = simulatedPointEstimation( t, p, d, 100, 3, noise );
    
    % Find and correct the mean
    [numu, ~, fig_handle] = removeOutliersFromMean( planes, n );
    
    % Save fig
    saveas(fig_handle, sprintf('%s/experiment_%d.fig',fld_full,i) );
    save(sprintf('%s/experiment_%d.mat',fld_full,i), 'planes', 'n', 'numu' );
    close all;
end