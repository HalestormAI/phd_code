clear,clc,close all,load testdata
tic
%% Init Vars
MAX_ITERATIONS = 3;
global colours;
global lmcalls;
colours = ['r','g','b','m','y','c'];
lmcalls = 0;
fld = getTodaysFolder( );
a        = dir(sprintf('./%s/run_*',fld));
next_id  = size(a,1) + 1;
fldfull = sprintf('%s/run_%03d',fld,next_id)
if ~exist(fldfull,'dir'),
    mkdir( fldfull );
end

ITERATION = 1;

if ~exist('midpoints','var')
    midpoints = coord2midpt(im_coords);
end


%% Develop initial set of regions
[regions,remaining] = generateRandomRegions( im_coords, im1, 6, 10 );
saveas(gcf, sprintf('%s/init_regions.fig',fldfull),'fig');
% [~, estplanes] = regionEstimates( regions, planes, im1, 50, 6  );
% gco_interface_ijh;
%% Relabel regions, REPEAT FOR n ITERATIONS
while ITERATION <= MAX_ITERATIONS
    numatt = 0;
    while (~exist('estplanes','var') || size(estplanes,1) < 1) && numatt < 5,
        [~, EP,~,fR] = regionEstimates( regions, planes, im1, 20, 6 );
        ITERATION
        fails{ITERATION}{numatt+1} = fR;
        if size(EP) >= 1
            estplanes = cleanEstimateSet( EP );
            if size(EP,1) ~= size(estplanes,1),
                disp('Estimates Combined: ');
                EP
                disp('To:')
                estplanes
            end
        end
        numatt = numatt + 1;
    end

    if size(estplanes,1) <= 1,
        if size(EP,1) <= 1,
            fprintf('No candidate planes have been found, fail at iteration: %d\n\n',ITERATION);
            break;
        else
            estplanes = EP;
            disp('Resetting to pre-cleaned estimate set.');
        end
    end

    gco_interface_ijh;

    labels = unique(labelling);
    regions = cell(length(labels),1);
    offset = 0;
    for l=1:length(labels),
        idxs = mpid2cid( find(labelling==labels(l)) );

%         if length(idxs) < 0.05*length(midpoints),
%             % discard region, store for reassignment
%             %regions(l) = [];
%             fprintf('Region %d is poor',l);
%             %offset = offset+1;
%         else
            regions{l} = im_coords(:,idxs);
%         end
    end
    planesFig = drawRegionPlanes( estplanes, regions, im_coords, planes );

    saveas( planesFig, sprintf('%s/iter%d_planes.fig',fldfull,...
            ITERATION),'fig');
% 
%     drawcoords(im_coords);
%     colours = ['r','g','b','m','y'];
%     for i=1:length(regions),
%         drawcoords(regions{i},'',0,colours(i));
%     end
    iters(ITERATION) = struct( ...
                                'estplanes',{estplanes}, ...
                                'regions',{regions}, ...
                                'labelling', {labelling}, ...
                                'smoothCost', {smoothCost.*SMOOTHCOEFF}, ...
                                'labelCost', {labelCost.*LABELCOEFF}, ...
                                'neighbourCost', {neighbourWeights.*NEIGHBOURCOEFF} ...
                             );
    ITERATION = ITERATION + 1;
    clear estimates estplanes;
end
beep;

EXECUTION_TIME = toc

save( sprintf('%s/data.mat',fldfull) );
