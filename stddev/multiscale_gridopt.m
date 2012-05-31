% Set up constants for iterator

D = 3;
FOC = 1;

GT_theta = 75;
GT_psi = -37;

params = [GT_theta, GT_psi];
constants = [D,FOC];

stddev = 1;
stddev_w = 0;
stddev_h = 1;

plane_details = createPlaneDetails( params, constants, [stddev,stddev_w, stddev_h] );


MAX_LEVEL = 3;
STEP = 10;

completeErrors = cell(MAX_LEVEL,1);
bestPick = zeros(MAX_LEVEL,2);
minErrors = zeros(MAX_LEVEL,1);
bestAngles = cell(MAX_LEVEL,1);
bestFocal = cell(MAX_LEVEL,1);
inits = cell(MAX_LEVEL,1);

for level=1:MAX_LEVEL
    if level == 1
        thetas = 1:STEP:89;
        psis = -60:STEP:60;
        focals = 10.^(-4:4);
    else
        STEP = STEP/10;
        range = (-10*STEP):STEP:(10*STEP);

        thetas = bestAngles{level-1}(1) + range;
        psis = bestAngles{level-1}(2) + range;
        if level==2
            focals = bestFocal{level-1}.*(-5:5);
        else
            focals = bestFocal{level-1}+bestFocal{1}.*((-5:5)/10^(level-1));
            % Cludge to stop crash!
        end
        focals(focals==0) = [];
    end

    [ssd_errors,minErrors(level),bestAngles{level},bestFocal{level},inits{level}] = iterator_parfor_foc( D, plane_details,thetas,psis,focals);
    theta_varies = (mean(ssd_errors,2));
    [max_error, max_id] = max(theta_varies);
    [min_error, min_id] = min(theta_varies);
    completeErrors{level} = ssd_errors;
 
end