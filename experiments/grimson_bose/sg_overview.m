
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
    imtraj = trajsg(cellfun(@max,bbox_areas) > T_bbox);
end

% 3.1 detecting constant velocity paths

% Filter paths (or sections thereof) to straight lines
% threshold related to distance moved
disp('Filtering paths to straight lines...');
[splitted, qualities] = cellfun(@(x) linSplitTrajectory(x),imtraj,'un',0);
qual = vertcat(qualities{:});
split = vertcat(splitted{:});

disp('Filtering based on length...');
% Check length is 2/5 of frame height and we have 25 points
px_lengths = cellfun(@trajPixelLength, split);
lengths = cellfun(@length, split);

valid = and(px_lengths >= T_width, lengths >= T_frames);
use = split(valid);


disp('Generating 1D representations of paths...');
% now get 1D representation of paths
paths = cellfun(@bose_calculate1Dcoords, use, 'un',0);
[Gs, linpaths] = cellfun(@bose_estimate1Dhomog,paths,'un',0);

% Have paths, now need to find ones that are around constant speed
disp('Getting constant speed paths...');
const_spd = zeros(length(paths),1);
for p=1:length(paths)
    reproj_err = bose_reprojection_error( paths{p}, linpaths{p}. Gs{p} );
    if reproj_err < T_reproj*paths{p}(end)
        const_spd = 1;
    end
end

constant_spd = use(const_spd);

fprintf('\n**********\nWe have %d valid trajectories.\n**********\n',length(constant_spd));


