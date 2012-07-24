function [planes, iTrajectories] = camera2image( planes, cTrajectories, alpha )
    for p=1:length(planes)
        planes(p).image = wc2im(planes(p).camera,alpha);
    end
    
    iTrajectories = cellfun(@(x) wc2im(x,alpha), cTrajectories,'un',0);
end