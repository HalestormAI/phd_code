button = questdlg('This will clear and close all...','Confirm','OK','Cancel','OK');

if ~strcmp(button,'OK'),
    return;
end
clear,clc,close all;
load singleplane;
plane.abc = plane.n./plane.d;

alphas = 10.^(-4:1);
alphas = [-alphas(end:-1:1),alphas];

starts = generateNormalSet( alphas );

errorsFull = cellfun(@(x) gp_iter_func(x,im_coords), num2cell(starts,2), 'UniformOutput',false);

errors = cell2mat(cellfun(@(x) [mean(x.^2), std(x.^2)], errorsFull, 'UniformOutput',false));


% starts(minidx,:)

% Get 1% of set with lowest error
[~,ix] = sort(errors);
x0s = starts(ix(1:round(length(ix)*0.01)),:);

%% Generate small, fine-grained grids around areas of low error
grids = cellfun(@generateFineGrid,num2cell(x0s,2));

%% Run optimsations and pick best
% [failReasons, passiters, x_iters, pass] = ...
%     runsForX0( im_coords, 1:length(im_coords), x0s, 1, -1 );
% 
% estimates = cell2mat(passiters)
% est_errors = cell2mat(cellfun(@(x) sum(gp_iter_func(x,im_coords).^2), cell2num(estimates,2), 'UniformOutput',false));
% 
% [~,minidx] = min(est_errors);
% 
% bestest = estimates(minidx,:)
% est.d = 1/norm(bestest(1:3))
% est.n = bestest(1:3).*est.d'
% est.alpha = bestest(4)

