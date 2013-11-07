function [planes, cTrajectories] = world2camera( planes, wTrajectories, params, rotationUnit )

    if ~isstruct( params )
        error('Usage of this function has changed. We now take a parameter struct as defined in `multiplane_params_example.m');
    end


    cameraOrientation = params.camera.rotation;
    if nargin < 4 || strcmp(rotationUnit,'degrees')
        cameraOrientation = deg2rad(cameraOrientation);
    end
    
    AoE = makehgtform('zrotate', cameraOrientation(1));
    AoY = makehgtform('xrotate', cameraOrientation(2));
    AoE = AoE(1:3,1:3);
    AoY = AoY(1:3,1:3);
    
    planes_trans = cell(length(planes),1);
    for p=1:length(planes)
        planes_trans{p} = planes(p).world - repmat(params.camera.position,1,4);
    end

    for i=1:length(planes)
        planes(i).camera = AoE*AoY*planes_trans{i};
    end
    cTrajectories = cellfun(@(x) AoE*AoY*(x-repmat(params.camera.position,1,size(x,2))), wTrajectories,'un',0);
    
    translation = mean(minmax([planes.camera]),2);
    translation(3) = 0;

    for i=1:length(planes)
        planes(i).camera = planes(i).camera - repmat(translation,1,size(planes(i).camera,2));
    end
    cTrajectories = cellfun(@(x) (x-repmat(translation,1,size(x,2))), cTrajectories,'un',0);

end


