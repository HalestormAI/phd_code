    function [traj,startframes,camTraj] = addTrajectoriesToPlane( worldPlane, rotation, MAX_TRAJ, NUM_FRAMES, MEAN_SPEED, STD_SPEED ) 


    %% Param check
    if nargin < 2,
        error('Need initial world-plane and rotation to camera plane');
    end
    if nargin < 3,
        MAX_TRAJ = 10;
    end
    if nargin < 4,
         NUM_FRAMES = 75;
    end
    if nargin < 5,
        MEAN_SPEED = 1;
    end
    if nargin < 6,
        STD_SPEED = 0.1*MEAN_SPEED;
    end

    %% Find edges of world-plane
    mins = min(worldPlane,[],2);
    maxs = max(worldPlane,[],2);
    planeBoundaries = [         mins(1),         maxs(1); 
                                mins(2),         maxs(2);
                        worldPlane(3,1), worldPlane(3,1)];

    traj    = { };
    prevdrn = { };
    speeds  = { };
    drnchg  = { };
    
    startframes = [];
                    

    h = waitbar(0,'Starting...', 'Name', sprintf('%d Frames', NUM_FRAMES));
    for t = 1:NUM_FRAMES,
        
    waitbar(t / NUM_FRAMES, h, sprintf('Frame: %d (%d%%).',t, round(100*t / NUM_FRAMES)));
        % 25% chance of spawn provided we have room
        if rand <= 0.25 && length(traj) < MAX_TRAJ,
            [traj{end+1}(:,1),prevdrn{end+1}] = initialiseNewPoint( );
            startframes(end+1) = t;
            s = normrnd(MEAN_SPEED,STD_SPEED,1,NUM_FRAMES-(t-1));
            speeds{end+1} = s;
            drnchg{end+1} = normrnd(0,2.5,1,NUM_FRAMES-(t-1));
        end
        
        for trajId = 1:length(traj),
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
delete(h)
    camTraj = cellfun(@(x) rotation(1:3,1:3)*x,traj,'uniformoutput',false);
    
    function [start ,prevdrn] = initialiseNewPoint( )
    % Pick a side of the plane to start at
        RR = randperm(4);
        
        % Add some type 1 noise
        t2n = rand*2;
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