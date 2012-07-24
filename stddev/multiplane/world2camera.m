function [planes, cTrajectories] = world2camera( planes, wTrajectories, cameraOrientation, rotationUnit )

    if nargin < 4 || strcmp(rotationUnit,'degrees')
        cameraOrientation = deg2rad(cameraOrientation);
    end
    
    AoE = makehgtform('zrotate', cameraOrientation(1));
    AoY = makehgtform('xrotate', cameraOrientation(2));
    AoE = AoE(1:3,1:3);
    AoY = AoY(1:3,1:3);
    
    
    for i=1:length(planes)
        planes(i).camera = AoE*AoY*planes(i).world;
    end
    cTrajectories = cellfun(@(x) AoE*AoY*x, wTrajectories,'un',0);
    
    translation = mean(minmax([planes.camera]),2);
    translation(3) = 0
    [planes.camera]

    for i=1:length(planes)
        planes(i).camera = planes(i).camera - repmat(translation,1,size(planes(i).camera,2));
    end
    cTrajectories = cellfun(@(x) (x-repmat(translation,1,size(x,2))), cTrajectories,'un',0);
    [planes.camera]

end


