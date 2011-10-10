function [estimates, estplanes, x0s, fR] = regionEstimates( regions, planes, im1, NUM_ATTEMPTS, NUM_VECS )

    if nargin < 4,
        NUM_ATTEMPTS = 10;
    end
    if nargin < 5,
        NUM_VECS = 4;
    end
    
    MAXRUNS = 10;
    
    % %Comment out this section if sim data exists.
    % multiplanar_sim
    % im_coords = round(wc2im(coords,-1/720));
    % im1 = zeros(fliplr(max(im_coords,[],2)'));
    % 
    % regions = generateRandomRegions( im_coords, im1, 5, 10 );

    estimates(1:length(regions)) = struct('planes',{zeros(NUM_ATTEMPTS,5)},...
                                          'meanplane',{zeros(1,5)},...
                                          'fails',zeros(NUM_ATTEMPTS,4),...
                                          'flags',zeros(NUM_ATTEMPTS,1),...
                                          'passes',zeros(1,5));
    failedRegions = [];
    for r=1:length(regions),

        if sum(size(regions{r})) < NUM_VECS*2,
            estimates(r).planes = [];
            estimates(r).passes = [];
            estimates(r).fails = [];
            estimates(r).flags = -999;
            estimates(r).meanplane = [];
            failedRegions = [failedRegions,r];
            continue;
        end
        
        possruns = nchoosek(size(regions{r},2)/2,NUM_VECS );
        
        passes = [];
        numruns = 0;
        % Allow for up to 100 different input vector sets (or the max
        % number of runs possible given input size)
        while numruns < min(possruns,MAXRUNS) && size(passes,1) < 1,
            
            ids = getVectorIds( regions{r}, NUM_VECS );
            [fR, x0s, xiters,p] = runWithErrors_sim( regions{r}, ids, im1, NUM_ATTEMPTS, -1 );
            p
            passes = xiters(sum(fR(:,1:4),2) == 0,:);
            if size(passes,1) < 1,
%                 fR
                fprintf('No Result (Run %d), clearing this!\n', numruns);
                estimates(r).planes = [];
                estimates(r).passes = [];
                estimates(r).fails = fR;
                estimates(r).flags = p;
                estimates(r).meanplane = [];
                failedRegions = [failedRegions,r];
                numruns = numruns + 1;
            else
                estimates(r).planes = xiters;
                estimates(r).passes = passes;
                estimates(r).fails = fR;
                estimates(r).flags = p;
                regioncentre = mean(regions{r},2);
                numu = removeOutliersFromMean(passes, ...
                        planes(getPlaneFromLocation(regioncentre,planes,'im')).n,0);
                estimates(r).meanplane = numu;
            end
        end
    end

    
    for i=length(estimates):-1:1
        if isempty(estimates(i).meanplane),
            estimates(i) = [];
        end
    end
    %[[planes.d];[planes.n]]
    estplanes=cell2mat(cellfun(@(x)[x(1),x(2:4)./norm(x(2:4)),x(5)],{estimates.meanplane}','UniformOutput',false));
    failedRegions
    

end