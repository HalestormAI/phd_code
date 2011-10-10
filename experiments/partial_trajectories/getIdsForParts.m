
    function [conIds, vecIds] = getIdsForParts( vP )
        previousPos = 0;
        for v=1:length(vP),
            i = (previousPos)+(1:length(vP{v}));
            conIds{v} = i;
            previousPos = max(i);
            
            vecIds{v} = mpid2cid([i,max(i)+1]);
        end
    end