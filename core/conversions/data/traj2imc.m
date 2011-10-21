function imc = traj2imc( traj, FPS )

if nargin < 2,
    FPS = 25;
end

pieces = round(traj(:, 1:FPS:end));

if size(pieces,2) > 1

    imc = zeros( 2, length(pieces - 1) );

    for p=1:length(pieces)-1;  
        imc(:,(2*p)-1:(2*p)) = pieces(:,p:p+1);
    end
else
    imc = [];
end