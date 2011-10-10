% REMAINING = MT;
% 
% 
% COMPONENTS = cell(1,1);
% 
% START = REMAINING(1,1);
% 
% COMPONENTS{1} = [START; REMAINING(REMAINING(:,1)==REMAINING(1,2),2)];
% 


% allnodes = unique(MT);
function COMPONENTS = getConnectedComponents( MT )

    remaining = MT;
    
    
    COMPONENTS = cell(1,1);
    
    count = 1;
    while size(remaining,1) > 0,
        allnodes = downTree( remaining, remaining(1,1), 0 );
        nodeSet = unique(allnodes);
        COMPONENTS{count} = nodeSet;
        count = count + 1;
        
        [~,AI]=intersect(remaining(:,1),nodeSet);
        [~,BI]=intersect(remaining(:,2),nodeSet);
        % Since we're only given LAST index, need to repeat until all done
        while ~isempty([AI,BI]),
            remaining(unique([AI,BI]),:) = [];
            [~,AI]=intersect(remaining(:,1),nodeSet);
            [~,BI]=intersect(remaining(:,2),nodeSet);
        end
    end

    function nodes = downTree( MT, curnode, level )
        
        if level >= 100,
            error('100 Recursions, probably broken');
        end
        
        nodes = [];
        
        % Get all nodes connected to this one in remaining list
        CONNECTED = MT(MT(:,1)==curnode,2);

        if isempty(CONNECTED),
            nodes = curnode;
        else
            % drop into tree at each node
            for c=1:length(CONNECTED),
                nodes = [nodes, curnode, downTree( MT, CONNECTED(c), level+1 )];
            end
        end
    end
end