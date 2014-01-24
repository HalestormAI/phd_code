function imc = traj2imc( traj, FPS, NOROUND )

if nargin < 2,
    FPS = 1;
end
if nargin < 3,
    NOROUND = 1;
end

if iscell( traj )
    imc = cellfun(@(x) traj2imc( x, FPS, NOROUND ), traj, 'uniformoutput',false);
    return;
end

pieces = (traj(:, 1:FPS:end));
if ~NOROUND
    pieces = round(pieces);
end

if size(pieces,2) > 2
    imc = zeros( size(pieces,1), length(pieces - 1) );
    for p=1:size(pieces,2)-1
        imc(:,(2*p)-1:(2*p)) = pieces(:,p:p+1);
    end
elseif size(pieces,2) == 2
    imc = traj;
else
    imc = [];
end