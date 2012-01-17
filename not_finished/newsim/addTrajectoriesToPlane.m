    function [traj,startframes,camTraj] = addTrajectoriesToPlane( ...
        worldPlane, rotation, MAX_TRAJ, NUM_FRAMES, MEAN_SPEED, ...
        STD_SPEED, WALK_SPD_VAR, DRN_VAR, startPoints, startDrns ) 


    %% Param check
    if nargin < 2,
        error('Need initial world-plane and rotation to camera plane');
    end
    if nargin < 3 || isempty(MAX_TRAJ),
        MAX_TRAJ = 10;
    elseif nargin >= 9
        MAX_TRAJ = length(startPoints);
    end
    if nargin < 4 || isempty(NUM_FRAMES),
         NUM_FRAMES = 75;
    end
    if nargin < 5 || isempty(MEAN_SPEED),
        MEAN_SPEED = 1;
    end
    if nargin < 6 || isempty(STD_SPEED),
        STD_SPEED = 0.1*MEAN_SPEED;
    end
    if nargin < 7 || isempty(WALK_SPD_VAR)
        WALK_SPD_VAR = 0.1*MEAN_SPEED;
    end
    if nargin < 8 || isempty(DRN_VAR)
        DRN_VAR = 2.5;
    end
    
    NORM_SPEEDS = normrnd( MEAN_SPEED, STD_SPEED, 1, MAX_TRAJ );

    %% Find edges of world-plane
    planeBoundaries = minmax(worldPlane);

    traj    = cell(MAX_TRAJ,1);
    prevdrn = cell(MAX_TRAJ,1);
    speeds  = cell(MAX_TRAJ,1);
    drnchg  = cell(MAX_TRAJ,1);
    
    startframes = [];
               
    num_trajectories = 0;

    h = waitbar(0,'Starting...', 'Name', sprintf('%d Frames', NUM_FRAMES));
    for t = 1:NUM_FRAMES,
        
    waitbar(t / NUM_FRAMES, h, sprintf('Frame: %d (%d%%).',t, round(100*t / NUM_FRAMES)));
        % 25% chance of spawn provided we have room
        if rand <= 1 && num_trajectories < MAX_TRAJ,
            
            this_spd = NORM_SPEEDS(num_trajectories+1);
            
            if nargin < 9
                [traj{num_trajectories+1}(:,1),prevdrn{num_trajectories+1}] = initialiseNewPoint( );
            else
                traj{num_trajectories+1}(:,1) = startPoints{num_trajectories+1};
                prevdrn{num_trajectories+1} = startDrns{num_trajectories + 1};
            end
            startframes(num_trajectories+1) = t;
            s = normrnd(this_spd,WALK_SPD_VAR,1,NUM_FRAMES-(t-1));
            speeds{num_trajectories+1} = s;
            drnchg{num_trajectories+1} = normrnd(0,DRN_VAR,1,NUM_FRAMES-(t-1));
            num_trajectories = num_trajectories + 1;
        end
        
        for trajId = 1:num_trajectories,
            % check if it's still active: is the last point inside the
            % plane?
            carryon = inpolygon(traj{trajId}(1,end),traj{trajId}(2,end),worldPlane(1,:),worldPlane(2,:));
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
                v(3) = 0;
                newpos = traj{trajId}(:,end) + v';
                
                % If still within the boundaries of the plane,
                % save into trajectory for this time-step
                stillin = inpolygon(newpos(1),newpos(2),worldPlane(1,:),worldPlane(2,:));
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
    end
        
    delete(h)
    if nargin < 2  || isempty(rotation)
        camTraj = [];
    else
        camTraj = cellfun(@(x) rotation(1:3,1:3)*x,traj,'uniformoutput',false);
    end
    function [start ,prevdrn] = initialiseNewPoint( )
    % Pick a side of the plane to start at
        RR = randperm(4);
        
        % Add some type 1 noise
%         t2n = rand*2;
        t2n = 0;
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

end