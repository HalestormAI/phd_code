    function [traj,startframes,camTraj,speeds,t2noises,endState] = addTrajectoriesToPlane( ...
        worldPlane, rotation, MAX_TRAJ, NUM_FRAMES, MEAN_SPEED, ...
        STD_SPEED, WALK_SPD_VAR, DRN_VAR, HEIGHT_VAR, INNER_HEIGHT_VAR, startPoints, startDrns ) 
    % Inputs:
    % worldPlane, rotation, MAX_TRAJ, NUM_FRAMES, MEAN_SPEED, 
    %    STD_SPEED, WALK_SPD_VAR, DRN_VAR, HEIGHT_VAR,  INNER_HEIGHT_VAR,
    %    startPoints, startDrns

    
    NODISPLAY = 1;
    %% Param check
    if nargin < 2,
        error('Need initial world-plane and rotation to camera plane');
    end
    if nargin < 3 || isempty(MAX_TRAJ),
        MAX_TRAJ = 10;
    elseif nargin >= 11
        MAX_TRAJ = length(startPoints);
    end
    if nargin < 4 || isempty(NUM_FRAMES),
         NUM_FRAMES = 75;
    end
    if nargin < 5 || isempty(MEAN_SPEED),
        MEAN_SPEED = 1;
    end
    if nargin < 6 || isempty(STD_SPEED),
        STD_SPEED = 0; %0.1*MEAN_SPEED;
    end
    if nargin < 7 || isempty(WALK_SPD_VAR)
        WALK_SPD_VAR = 0;%0.1*MEAN_SPEED;
    end
    if nargin < 8 || isempty(DRN_VAR)
        DRN_VAR = deg2rad(10);
    end
    if nargin < 9 || isempty(HEIGHT_VAR)
        HEIGHT_VAR = 0;
    end
    if nargin < 10 || isempty(INNER_HEIGHT_VAR)
        INNER_HEIGHT_VAR = 0;
    end
    
    % Implement skewed gaussian
%     NORM_SPEEDS = randsn( MEAN_SPEED*5, MEAN_SPEED/2, STD_SPEED.*MEAN_SPEED, 1, MAX_TRAJ);
    NORM_SPEEDS = normrnd( MEAN_SPEED*100, STD_SPEED*100, 1, MAX_TRAJ )./100;
    t2noises = normrnd( 0, HEIGHT_VAR,1, MAX_TRAJ );

    %% Find edges of world-plane
    planeBoundaries = minmax(worldPlane);

    traj    = cell(MAX_TRAJ,1);
    prevdrn = cell(MAX_TRAJ,1);
    speeds  = cell(MAX_TRAJ,1);
    drnchg  = cell(MAX_TRAJ,1);
    hgtvar  = cell(MAX_TRAJ,1);
    
    endState(MAX_TRAJ) = struct('spd',0,'drn',0,'pos',zeros(1,3));
    
    startframes = [];
               
    num_trajectories = 0;

    scrnsz = get(0,'Screensize');
    if length(find(scrnsz(3:4)==1)) ~= 2 && ~NODISPLAY
        h = waitbar(0,'Starting...', 'Name', sprintf('%d Frames', NUM_FRAMES));
    end
    for t = 1:NUM_FRAMES,
        
        if length(find(scrnsz(3:4)==1)) ~= 2 && ~NODISPLAY
            waitbar(t / NUM_FRAMES, h, sprintf('Frame: %d (%d%%).',t, round(100*t / NUM_FRAMES)));
        else
            if mod(t,200) == 0
                
                str = sprintf('Frame %4d of %4d (%3d%%)\n', t, NUM_FRAMES, ...
                        round(100*t/NUM_FRAMES));
                    
                lenStr = length(str);
                 if t > 200
                     blankstr = '';
                     for bb=1:lenStr
                         blankstr = strcat(blankstr,'\b');
                     end
                     fprintf(blankstr);
                 end
                 fprintf('%s',str)
            end
        end
        % 25% chance of spawn provided we have room
        if rand <= 1 && num_trajectories < MAX_TRAJ,
            
            this_spd = NORM_SPEEDS(num_trajectories+1);
            
            if nargin < 11
                [traj{num_trajectories+1}(:,1),prevdrn{num_trajectories+1}] = initialiseNewPoint( t2noises(num_trajectories+1) );
            else
                traj{num_trajectories+1}(:,1) = startPoints{num_trajectories+1};
                prevdrn{num_trajectories+1} = startDrns{num_trajectories + 1};
            end
            startframes(num_trajectories+1) = t;
            
            s = normrnd(this_spd,WALK_SPD_VAR,1,NUM_FRAMES-(t-1));
            speeds{num_trajectories+1} = s;
            drnchg{num_trajectories+1} = normrnd(0,rad2deg(DRN_VAR),1,NUM_FRAMES-(t-1));
            hgtvar{num_trajectories+1} = normrnd(0,INNER_HEIGHT_VAR,1,NUM_FRAMES-(t-1));
            num_trajectories = num_trajectories + 1;
        end
        
        for trajId = 1:num_trajectories,
            % check if it's still active: is the last point inside the
            % plane?
%             carryon = inpolygon(traj{trajId}(1,end),traj{trajId}(2,end),worldPlane(1,:),worldPlane(2,:));
            
            carryon = onPlane( traj{trajId}(:,end), worldPlane );
            
            if ~carryon
                continue;
            end
            % if we're still going:
                t0 = startframes(trajId);
                % Take speed from distribution for this time-step
                spd = speeds{trajId}(t-t0+1);
                % Get direction from previous direction +/- <5 degrees
                %drnchg = rand(1)*45-22.5;
                drn = prevdrn{trajId} + drnchg{trajId}(t-t0+1);

                % find location of new point on plane
                v(1) = spd*cos(deg2rad(drn));
                v(2) = spd*sin(deg2rad(drn));
                v(3) = hgtvar{trajId}(t-t0+1); % Add a few cm variation in height, taken at random from normal distribution
                newpos = traj{trajId}(:,end) + v';
                endState(trajId) = struct('spd',spd,'drn',drn,'pos',newpos);
                
                % If still within the boundaries of the plane,
                % save into trajectory for this time-step
%                 stillin = inpolygon(newpos(1),newpos(2),worldPlane(1,:),worldPlane(2,:));
                stillin = onPlane( newpos, worldPlane );
                if ~stillin,
                    continue;
                end
                
                prevdrn{trajId} = drn;
                traj{trajId}(:,end+1) = newpos;
        end
    end
    
    if num_trajectories < MAX_TRAJ
        traj(num_trajectories+1:end) = [];
        prevdrn(num_trajectories+1:end) = [];
        speeds(num_trajectories+1:end) = [];
        drnchg(num_trajectories+1:end) = [];
        endState(num_trajectories+1:end) = [];
    end
    
    
        
    if length(find(scrnsz(3:4)==1)) ~= 2 && ~NODISPLAY
        delete(h);
    end
    if nargin < 2  || isempty(rotation)
        camTraj = [];
    else
        camTraj = cellfun(@(x) rotation(1:3,1:3)*x,traj,'uniformoutput',false);
    end
    function [start ,prevdrn] = initialiseNewPoint( t2n )
    % Pick a side of the plane to start at
        RR = randperm(4);
        
        if nargin < 1
            t2n = 0;
        end

        if RR(1) == 1,
            % Start at the top of the plane
            start(1) = planeBoundaries(1,1)+rand(1)*planeBoundaries(1,2);
            start(2) = planeBoundaries(2,1);
            start(3) = planeBoundaries(3,1)+t2n;
            % Initial direction is down 
            prevdrn = 90;
        elseif RR(1) == 2,
            % Start on right
            start(1) = planeBoundaries(1,2);
            start(2) = planeBoundaries(2,1)+rand(1)*planeBoundaries(2,2);
            start(3) = planeBoundaries(3,1)+t2n;
            % Initial direction is left (180 deg)
            prevdrn = 180;
        elseif RR(1) == 3
            % Start at bottom
            start(1) = planeBoundaries(1,1)+rand(1)*planeBoundaries(1,2);
            start(2) = planeBoundaries(2,2);
            start(3) = planeBoundaries(3,1)+t2n;
            % Initial direction is up
            prevdrn = 270;
        else
            % start on left
            start(1) = planeBoundaries(1,1);
            start(2) = planeBoundaries(2,1)+rand(1)*planeBoundaries(2,2);
            start(3) = planeBoundaries(3,1)+t2n;
            % initial direction is right (0 deg)
            prevdrn = 0;
        end
    end

        function on = onPlane( point, plane )
            
            point(3,:) = [];

            mins = min(plane(1:2,:),[],2);
            maxs = max(plane(1:2,:),[],2);
            
            on = 1;
            
            if find(point < mins, 1, 'first')
                on = 0;
                return;
            elseif find(point > maxs, 1, 'last')
                on = 0;
                return;
            end 
            
        end

end
