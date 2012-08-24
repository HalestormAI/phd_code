function [ output_params, finalError, fullErrors, inits, E_angles, E_focals ] = multiplane_multiscaleSolver_using_imagewidth( D, plane_details, MAX_LEVEL, STEP, TOL )

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
inits      =  cell(MAX_LEVEL,1);

if isfield( plane_details, 'imagewidth' )
    focalInit = 1/plane_details.imagewidth;
else
    imdim = range( [plane_details.trajectories{:}], 2 );
    focalInit = 1/imdim(1);
end

% Now scale focalInit to nearest power of 10
roundScale = 10.^(-5:5);
if focalInit < min(roundScale)
    focalScale = min(roundScale);
elseif focalInit > max(roundScale)
    focalScale = max(roundScale);
else
    focalScale = interp1(roundScale, roundScale, focalInit, 'nearest');
end


for level=1:MAX_LEVEL
    if level == 1
        thetas = 1:STEP:89;
        psis = -90:STEP:90;
        focals = (focalScale/2):(focalScale/2.5):((focalScale*10)/2);
    else
        STEP = STEP/10;
        sRange = (-10*STEP):STEP:(10*STEP);

        thetas = E_angles(level-1,1) + sRange;
        psis = E_angles(level-1,2) + sRange;
        focals = (E_focals(level-1)-focalScale/2.5):(focalScale/10):(E_focals(level-1)+focalScale/2.5);
        % Cludge to stop crash!
        focals(focals==0) = [];
    end
    
    [fullErrors{level},minErrors(level),E_angles(level,:),E_focals(level), inits{level}] = iterator_parfor_foc( D, plane_details,thetas,psis,focals);
    
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
