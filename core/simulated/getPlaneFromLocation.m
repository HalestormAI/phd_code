 function pln = getPlaneFromLocation( pos, planes, mode )
    if nargin < 3,
        mode = 'wc';
    end
 
    pln = 0;
    for p=1:length(planes),
        if strcmp(mode,'wc'),
            inx = pos(1) >= min(planes(p).points(1,:)) && pos(1) <= max(planes(p).points(1,:));
            iny = pos(2) >= min(planes(p).points(2,:)) && pos(2) <= max(planes(p).points(2,:));
        else
            inx = pos(1) >= min(planes(p).impoints(1,:)) && pos(1) <= max(planes(p).impoints(1,:));
            iny = pos(2) >= min(planes(p).impoints(2,:)) && pos(2) <= max(planes(p).impoints(2,:));
            
        end
        if inx && iny,
            pln = p;
            return;
        end
    end
    if pln == 0,
        exp = MException('IJH:MULTIPLANE:OFFPLANE','Tracked Object has left the plane');
        pos
        throw(exp);
    end
end