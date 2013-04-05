% Set up constants for iterator

D = 100;
FOC = 0.0014;

thetas = 35;%70:-15:20;
psis = 20;%-40:15:40;

orientations = zeros( length(thetas)*length(psis), 2 );

count = 1;
for t=1:length(thetas)
    for p=1:length(psis)
        orientations(count,:) = [thetas(t),psis(p)];
        count = count + 1;
    end
end

scale = [D,FOC];

stddev    = 0;
stddev_w  = 0;
stddev_h  = 0;

stddevs = 0:0.2:1;


NUM_EXPS = length(stddevs);

% Init loop parameters
camPlanes     = cell(NUM_EXPS,length(orientations));
imPlanes      = cell(NUM_EXPS,length(orientations));
camTrajs      = cell(NUM_EXPS,length(orientations));
imTrajs       = cell(NUM_EXPS,length(orientations));
params        = cell(NUM_EXPS,length(orientations));
errors        = cell(NUM_EXPS,length(orientations));
angleErrors   = cell(NUM_EXPS,length(orientations));
fullErrors   = cell(NUM_EXPS,length(orientations));

for h=1:NUM_EXPS
    stddev = stddevs(h);
    for o=1:size(orientations,1)
        plane_details = createPlaneDetails( orientations(o,:), scale, [stddev,stddev_w, stddev_h] );
        GT_N = normalFromAngle( orientations(o,1), orientations(o,2) );

        camPlanes{h,o}  = plane_details.camPlane;
        imPlanes{h,o}   = plane_details.imPlane;
        camTrajs{h,o}   = plane_details.camTraj;
        imTrajs{h,o}    = plane_details.trajectories;

%         try
            [params{h,o},errors{h,o},fullErrors{h,o}] = multiscaleSolver( D, plane_details );
%         catch
%             params{h,o} = [NaN,NaN,NaN];
%             errors{h,o} = NaN;
%             fullErrors{h,o} = [NaN,NaN];
%             drawPlane(plane_details.camPlane);
%             drawtraj(plane_details.camTraj,'',0);
%         end

        angleErrors{h,o} = angleError( normalFromAngle( params{h,o}(1), params{h,o}(2) ), GT_N, 1);
        fprintf('## Orientation  %d of %d in speed set %d of %d ##\n',o, length(orientations), h, NUM_EXPS);
    end
    fprintf('*** Finished Speed Set %d of %d ***\n',h, NUM_EXPS);
end



save speedvar_data_withprior
