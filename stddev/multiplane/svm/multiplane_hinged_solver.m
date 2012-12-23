function [ output_params, finalError, fullErrors, inits, E_angles, E_ds, errorvecs ] = multiplane_hinged_solver( plane_details, CONSTRAINTS, FOCAL, INIT_D, MAX_LEVEL, STEP, TOL )

    if nargin < 5
        MAX_LEVEL = 3;
    end
    if nargin < 6
        STEP = 10;
    end

    if nargin < 7
        TOL = 1e-6;
    end

%     plane_details, CONSTRAINTS, FOCAL, INIT_D, MAX_LEVEL, STEP, TOL

   
    fullErrors =  cell(MAX_LEVEL,1);
    minErrors  = zeros(MAX_LEVEL,1);
    E_angles   = zeros(MAX_LEVEL,2);
    E_ds       = zeros(MAX_LEVEL,1);
    inits      =  cell(MAX_LEVEL,1);
    errorvecs  =  cell(MAX_LEVEL,1);

    %% Imagewidth Section for alpha localisation
    % Either get the given image width or get rough one from trajectories
    if isfield( plane_details, 'imagewidth' )
        focalInit = 1/plane_details.imagewidth;
    else
        imdim = range( [plane_details.trajectories{:}], 2 );
        focalInit = 1/imdim(1);
    end

    %% Localisation of d
    D_scale = log10(INIT_D);
    if D_scale <= 0
        D_scale = 1;
    end
        

    %% Iterate over iterations

    for level=1:MAX_LEVEL
        if level == 1
            thetas = 1:STEP:89;
            psis = -90:STEP:90;
            ds = INIT_D + [D_scale-5*D_scale:D_scale:D_scale+5*D_scale]
        else
            STEP = STEP/10;
            sRange = (-10*STEP):STEP:(10*STEP);

            thetas = E_angles(level-1,1) + sRange;
            psis = E_angles(level-1,2) + sRange;

            ds = E_ds(level-1) + [D_scale-5*D_scale:D_scale:D_scale+5*D_scale]
        end

        % Cludge to fix it to sensible values
        ds(ds<=0) = [];
        
        if isempty(ds)
            error('NO DS REMAINING!');
        end
        
%         levelWeight = 1*10^(-(MAX_LEVEL-level));
        levelWeight = 1000;
        
        [fullErrors{level},minErrors(level),E_angles(level,:), E_ds(level), inits{level}, errorvecs{level}] = multiplane_hinged_iterator( plane_details.trajectories,thetas,psis,ds,FOCAL,CONSTRAINTS,levelWeight);
        
%         if level > 1 && minErrors(level) > minErrors(level-1)
%             disp('Iteration stopped due to error increase.');
%             level
%             level = level -1;
%             break;
%         else
        if minErrors(level) < TOL
            disp('Error below tolerance, ending now.');
            break
        end
        D_scale = D_scale / 10;

    end

    output_params = [ E_angles(level,:), E_ds(level)];
    finalError = minErrors(level);

end

