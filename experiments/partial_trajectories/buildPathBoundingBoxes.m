function boxes = buildPathBoundingBoxes( paths )

    for i=1:length(paths),
        MAXES = max(paths{i},[],2);
        MINS  = min(paths{i},[],2);
        boxes{i} = [ MAXES(1), MAXES(1),  MINS(1),  MINS(1) ;
                     MAXES(2),  MINS(2),  MINS(2), MAXES(2) ];
    end
end