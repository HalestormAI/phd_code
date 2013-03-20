
% Generic formulae from section 2
% P = eye(3);
% A = eye(3);
%
% P(3,:) = vanishing_line;
% A(1,:) = [ 1/beta, -alpha/beta 0 ];
%
% circle_alpha =(dx1*dy1 - dx2*dy2*s^2) / ...
%               (dy1^2 - (s^2)*(dy2^2)) );
% radius = abs( s*(dx2*dy1 - dx1*dy2) / ...
%               (dy1^2 - (s^2)*(dy2^2)) );



% Set up parameters
T_width  = 0.4*size(frame,1);
T_frames = 25;
T_bbox   = 0.25*size(frame,1)*size(frame,2);
T_reproj = 0.2;

disp('Loading Trajectories...');
if ~exist('frame','var')
    error('Frame not set (make sure you''re using the right size version!)');
end

if exist('fromklt','var') && fromklt
    % If input is from KLT, check it's not in coords format and convert
    % if necessary.
    if iscoords( imtraj{1} )
        imtraj = imc2traj( imtraj );
    end
    
elseif ~exist('bbox_areas','var')
    error('Bounding Box areas not set');
elseif ~exist('trajsg','var')
    error('No trajectories were given!');
else
    % remove all trajectories with too-large a bounding box
    imtraj = trajsg(cellfun(@max,bbox_areas) <= T_bbox);
end

% Pre-filter all that are less than 25 frames long...
lengths = cellfun(@length, imtraj);
imtraj(lengths < T_frames) = [];

% 3.1 detecting constant velocity paths

% Filter paths (or sections thereof) to straight lines
% threshold related to distance moved
disp('Filtering paths to straight lines...');


num_cores = matlabpool('size');

if num_cores < 1
    matlabpool 3;
    num_cores = 3;
end

% splitted    = cell(10*length(imtraj),1);
% qualities   = cell(10*length(imtraj),1);

idlength    = ceil(length(imtraj)/num_cores);

coresplit   = Composite( );
corequality = Composite( );
coreids     = Composite( );
spmd
    
    worker_id = labindex;
    % Worker-specific parameters
    coresplit   =  cell(10*length(imtraj),1);
    corequality =  cell(10*length(imtraj),1);
    coreids     = zeros(10*length(imtraj),1);
    
    pos = 1;
    st  = (worker_id-1)*idlength+1;
    nd  = st+idlength - 1;
    if nd > length(imtraj) % Sanity check
        nd = length(imtraj);
    end
    % Run the loop for this worker
    for t=st:nd
        [s,q]     = linSplitTrajectory(imtraj{t});
        num_added = length(s);
        new_pos   = pos + num_added-1;
        
        coresplit(pos:new_pos)   = s';
        corequality(pos:new_pos) = num2cell(q);
        coreids(pos:new_pos)     = t; % Store the trajectory id for each trajectory

        pos = new_pos+1;
    end
    % clear out the leftovers
    coresplit(cellfun(@isempty,coresplit))     = [];
    corequality(cellfun(@isempty,corequality)) = [];
    coreids(~logical(coreids))                  = [];
end

% Cellfun version of the above parallel section
% [splitted, qualities] = cellfun(@(x) linSplitTrajectory(x),imtraj,'un',0);
split = vertcat(coresplit{:})';
qual  = vertcat(corequality{:})';
ids   = vertcat(coreids{:})';


disp('Filtering based on length...');
% Check length is 2/5 of frame height and we have 25 points
px_lengths = cellfun(@trajPixelLength, split);
lengths = cellfun(@length, split);

valid = and(px_lengths >= T_width, lengths >= T_frames);

if ~sum(valid)
    error('No valid trajectories!');
end

use     = split(valid);
use_ids = ids(valid);

disp('Generating 1D representations of paths...');
% now get 1D representation of paths
paths = cellfun(@bose_calculate1Dcoords, use, 'un',0);
[Gs, linpaths] = cellfun(@bose_estimate1Dhomog,paths,'un',0);

% Have paths, now need to find ones that are around constant speed
textprogressbar('Getting constant speed paths...');
const_spd = zeros(length(paths),1);
parfor p=1:length(paths)
    [reproj_err] = bose_reprojection_error( linpaths{p}, paths{p}, Gs{p} );
    
    if reproj_err < T_reproj*paths{p}(end)
        const_spd(p) = 1;
    end
%     f = figure;
%     plot(1:length(linpaths{p}),linpaths{p},'b-o'); hold on;
%     plot(1:length(paths{p}),paths{p},'r-*'); 
%     axis equal;
%     pause
%     close(f);
%     textprogressbar(100*p/length(paths));
end
textprogressbar('Done.');

constant_spd = use(logical(const_spd));
constant_gs  = Gs(logical(const_spd));

fprintf('\n**********\nWe have %d valid trajectories.\n**********\n',length(constant_spd));


[P,V_l] = bose_affine_rectify( constant_spd, constant_gs, frame );

% Now have Projective matrix, need to apply to all image trajectories
affine_traj = rectify_trajectories( use, P );


unique_ids           = unique(use_ids);
segments_per_traj    = zeros(length(unique_ids),1);
raw_traj_segments    =  cell(length(unique_ids),1);
raw_traj_ids         =  cell(length(unique_ids),1);
for I=1:length(unique_ids)
    segments_per_traj(I) =         sum(use_ids == unique_ids(I));
    raw_traj_segments{I} = affine_traj(use_ids == unique_ids(I));
    raw_traj_ids{I}      = repmat(unique_ids(I),segments_per_traj(I),1);
end

% Now select only those with more than 1 segment
valid_for_type_b = segments_per_traj > 1;
type_b_traj_segments_cell = raw_traj_segments(valid_for_type_b);
type_b_traj_ids_cell      =      raw_traj_ids(valid_for_type_b);

type_b_traj_segments = horzcat(type_b_traj_segments_cell{:})';
type_b_traj_ids      = vertcat(type_b_traj_ids_cell{:});

% Get circles and intersects
[circ_constraints] = bose_generate_circles( type_b_traj_segments, type_b_traj_ids );
[isct,isct_0] = circle_intersection( circ_constraints );

A = eye(3);
A(1,1) = 1/isct(2);
A(1,2) = -isct(1)/isct(2);

figure;
hold on;
for c = 1:length(circ_constraints)
    cc = circ_constraints(c,:);
    plot_circle( cc(1),cc(2), cc(3) );
end
scatter(isct(1), isct(2), 'ro','filled');
scatter(isct_0(1), isct_0(2), 'go','filled');
axis equal;
ax = axis;
plot([ax(1),ax(2)],[0,0],'r-');
xlabel('alpha');
ylabel('beta');