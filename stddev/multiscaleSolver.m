function [ output_params, finalError, fullErrors, inits ] = multiscaleSolver( D, plane_details, MAX_LEVEL, STEP, TOL, FSTEP )

if nargin < 3
    MAX_LEVEL = 3;
end
if nargin < 4
    STEP = 10;
end

if nargin < 5
    TOL = 1e-6;
end

if nargin < 6
    FSTEP = 1;
end

STEP_0 = STEP;

fsolve_options;
options = optimset('TolFun',TOL);

fullErrors =  cell(MAX_LEVEL,1);
inits =  cell(MAX_LEVEL,1);
minErrors  = zeros(MAX_LEVEL,1);
E_angles   = zeros(MAX_LEVEL,2);
E_focals   = zeros(MAX_LEVEL,1);

for level=1:MAX_LEVEL
    if level == 1
        thetas = 1:STEP:89;
        psis = -45:STEP:45;
        focals = 10.^(-4:FSTEP:1);
    else
        STEP = STEP/10;
        range = (-20*STEP):2*STEP:(20*STEP);

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
    warning('REMEMBER TO TAKE OUT FOCALS FIX (multiscaleSolver, line 49');
    focals = 0.0014;
    thetas,psis,focals
    [fullErrors{level},minErrors(level),E_angles(level,:),E_focals(level),inits{level}] = iterator_LM( D, plane_details,thetas,psis,focals, options);
    
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
