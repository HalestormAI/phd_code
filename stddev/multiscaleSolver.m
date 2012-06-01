function [ output_params, finalError, fullErrors ] = multiscaleSolver( D, plane_details, MAX_LEVEL, STEP, TOL )

if nargin < 3
    MAX_LEVEL = 3;
end
if nargin < 4
    STEP = 10;
end

if nargin < 5
    TOL = 1e-6;
end

fullErrors =  cell(MAX_LEVEL,1);
minErrors  = zeros(MAX_LEVEL,1);
E_angles   = zeros(MAX_LEVEL,2);
E_focals   = zeros(MAX_LEVEL,1);

for level=1:MAX_LEVEL
    if level == 1
        thetas = 1:STEP:89;
        psis = -60:STEP:60;
        focals = 10.^(-4:4);
    else
        STEP = STEP/10;
        range = (-10*STEP):STEP:(10*STEP);

        thetas = E_angles(level-1,1) + range;
        psis = E_angles(level-1,2) + range;
        if level==2
            focals = E_focals(level-1).*(-5:5);
        else
            focals = E_focals(level-1)+E_focals(1).*((-5:5)/10^(level-1));
        end
        % Cludge to stop crash!
        focals(focals==0) = [];
    end
    
    [fullErrors{level},minErrors(level),E_angles(level,:),E_focals(level)] = iterator_parfor_foc( D, plane_details,thetas,psis,focals);
    
    if level > 1 && minErrors(level) > minErrors(level-1)
        disp('Iteration stopped due to error increase.');
        level
        level = level -1;
        break;
    elseif minErrors(level) < TOL
        disp('Error below tolerance, ending now.');
        break
    end
    
end

output_params = [ E_angles(level,:), E_focals(level)];
finalError = minErrors(level);
end
