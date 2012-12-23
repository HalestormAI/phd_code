function [ output_params, E_thetas E_psis, E_focals ] = multiplane_combined_solver( regions, imagewidth, MAX_LEVEL, STEP, TOL )

    if nargin < 4
        MAX_LEVEL = 2;
    end
    if nargin < 5
        STEP = 10;
    end

    if nargin < 6
        TOL = 1e-6;
    end
    
    D = 1;
    
    minErrors  = zeros(MAX_LEVEL,1);
    E_thetas   =  cell(MAX_LEVEL,1);
    E_psis     =  cell(MAX_LEVEL,1);
    E_focals   = zeros(MAX_LEVEL,1);

    %% Imagewidth Section for alpha localisation
    % Either get the given image width or get rough one from trajectories
    if nargin >= 2
        focalInit = 1/imagewidth;
    else
        allTraj = [regions.traj];
        imdim = range( [allTraj{:}], 2 );
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
        

    %% Iterate over iterations

    for level=1:MAX_LEVEL
        fprintf( 'Beginning Level %d\n*****************\n', level );
        % TODO: after level 1, make several multi-resolution search grids
        % and pass as cell
        if level == 1
            thetas = 1:STEP:89;
            psis = -90:STEP:90;
            focals = (focalScale/2):(focalScale/2.5):((focalScale*10)/2);
        else
            STEP = STEP/10;
            sRange = (-10*STEP):2*STEP:(10*STEP);

            thetas = [];
            psis   = [];
            for r=1:length(regions)
                thetas = [thetas,E_thetas{level-1}(r) + sRange];
                psis = [psis,E_psis{level-1}(r) + sRange];
            end
            thetas = unique(thetas);
            psis = unique(psis);

            focals = (E_focals(level-1)-focalScale/2.5):(focalScale/10):(E_focals(level-1)+focalScale/2.5);
        end

        % Cludge to stop crash!
        focals(focals==0) = [];
        
        E_regions = combined_alpha_iterator( focals, thetas, psis, D, regions );
        [~,minErrors(level),E_focals(level),E_thetas{level},E_psis{level}] = hypotheses_from_region_errors( regions, E_regions, focals, thetas, psis );

        E_focals(level)
        E_thetas{level}
        E_psis{level}
        
        fn = sprintf('leveldata_%d.mat',level);
        
        save(fn,'E_*','minErrors','regions','E_regions','focals', 'thetas', 'psis', 'D');
        
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

    output_params = [ E_thetas{level}, E_psis{level}, repmat(E_focals(level),length(regions),1) ];

end

