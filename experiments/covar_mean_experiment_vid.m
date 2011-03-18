close all;
clear;
clc;

fld      = getTodaysFolder( );
fld_full = sprintf('%s/students_covar_outlierremoval', fld);
mkdir( fld_full );

load('students003_data');

[~,planes,n,used_vectors] = videoPointEstimation( im_coords, N.a, 100, 3, 1, 'Students003' );

% Find and correct the mean
[numu, ~, fig_handle] = removeOutliersFromMean( planes, n );

% Save fig
% find next exp_num
l = dir( strcat( fld_full, '/experiment_*.fig' ) );
i = size(l, 1);

saveas(fig_handle, sprintf('%s/experiment_%d.fig',fld_full,i) );
save(sprintf('%s/experiment_%d.mat',fld_full,i), 'planes', 'n', 'numu', 'used_vectors' );
close all;