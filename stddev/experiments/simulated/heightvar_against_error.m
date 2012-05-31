% Set up constants for iterator
D = 3;
FOC = 1;

thetas = 80:-20:10;
psis = -50:25:50;

orientations = zeros( length(thetas)*length(psis), 2 );

count = 1;
for t=1:length(thetas)
    for p=1:length(psis)
        orientations(count,:) = [thetas(t),psis(p)];
        count = count + 1;
    end
end

GT_theta = 75;
GT_psi = -37;

GT_N = normalFromAngle( GT_theta, GT_psi );

orientation = [GT_theta, GT_psi];
scale = [D,FOC];

stddev    = 0;
stddev_w  = 0;

stddev_hs = 0:0.2:2;

NUM_EXPS = length(stddev_hs);

% Init loop parameters
camPlanes     = cell(NUM_EXPS,length(orientations));
imPlanes      = cell(NUM_EXPS,length(orientations));
camTrajs      = cell(NUM_EXPS,length(orientations));
imTrajs       = cell(NUM_EXPS,length(orientations));
params        = cell(NUM_EXPS,length(orientations));
errors        = cell(NUM_EXPS,length(orientations));
angleErrors   = cell(NUM_EXPS,length(orientations));

for h=1:NUM_EXPS
    stddev_h = stddev_hs(h);
    for o=1:length(orientations)
        plane_details = createPlaneDetails( orientations(o,:), scale, [stddev,stddev_w, stddev_h] );

        camPlanes{h,o}  = plane_details.camPlane;
        imPlanes{h,o}   = plane_details.imPlane;
        camTrajs{h,o}   = plane_details.camTraj;
        imTrajs{h,o}    = plane_details.trajectories;

        [params{h,o},errors{h,o}] = multiscaleSolver( D, plane_details );

        angleErrors{h,o} = angleError( normalFromAngle( params{h,o}(1), params{h,o}(2) ), GT_N, 1);
    end
    fprintf('*** Finished Height Set %d of %d ***',h, NUM_EXPS);
end


