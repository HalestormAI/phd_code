% Set up constants for iterator

D = 100;
FOC = 0.0014;

thetas = 70:-15:20;
psis = -40:15:40;

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

stddevs = 0:0.1:1;

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

if ~exist('EXP_START','var') || ~exist('EXP_END','var')
    EXP_START = 1;
    EXP_END = NUM_EXPS;
end

for h=EXP_START:EXP_END
    stddev_h = stddevs(h);
    for o=1:length(orientations)
        plane_details = createPlaneDetails( orientations(o,:), scale, [stddev,stddev_w, stddev_h] );
        GT_N = normalFromAngle( orientations(o,1), orientations(o,2) );

        camPlanes{h,o}  = plane_details.camPlane;
        imPlanes{h,o}   = plane_details.imPlane;
        camTrajs{h,o}   = plane_details.camTraj;
        imTrajs{h,o}    = plane_details.trajectories;

%         try
            [params{h,o},errors{h,o},fullErrors{h,o}] = multiscaleSolver( D, plane_details, 3, 20, 1e-5 );
%         catch
%             params{h,o} = [NaN,NaN,NaN];
%             errors{h,o} = NaN;
%             fullErrors{h,o} = [NaN,NaN];
%             drawPlane(plane_details.camPlane);
%             drawtraj(plane_details.camTraj,'',0);
%         end

        angleErrors{h,o} = angleError( normalFromAngle( params{h,o}(1), params{h,o}(2) ), GT_N, 1);
        fprintf('## Orientation  %d of %d in height set %d of %d ##\n',o, length(orientations), h, NUM_EXPS);
    end
    iter_errors = errors(h,:);
    iter_params = params(h,:);
    iter_fullerrors = fullErrors(h,:);
    iter_angleErrors = angleErrors(h,:);
    iter_imTrajs = imTrajs(h,:);
    iter_camTrajs = camTrajs(h,:);
    save(sprintf('heightvar_data_h=%d.mat',h),'iter_errors','iter_imTrajs','iter_params','iter_fullerrors','iter_angleErrors', 'orientations');
    fprintf('*** Finished Height Speed Set %d of %d ***\n',h, NUM_EXPS);
end



save heightvar_data_withprior
