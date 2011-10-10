function [closedpaths,openpaths] = findTrajectories( TIMES, ASSIGN )


    openpaths   = struct('t_start',{},'path',{});
    closedpaths = struct('t_start',{},'path',{});
    
    for i=1:size(ASSIGN{2},1),
        openpaths(i).t_start = 1;
        openpaths(i).path = i;
    end
    
    for t=2:length(TIMES),
        % search all open paths
        toremove = [];
        for p=1:length(openpaths),
            % If path length < t-p.t_start copy to closed paths and remove from
            % open
            if length(openpaths(p).path) < t-openpaths(p).t_start,
                cid = length(closedpaths)+1;
                closedpaths(cid).t_start = openpaths(p).t_start;
                closedpaths(cid).path = openpaths(p).path;
                toremove = [toremove,p];
            end
        end
        
       openpaths(toremove) = [];

        [I,J] = ind2sub(size(ASSIGN{t}),find(ASSIGN{t}));
        for i=1:length(I),
        % search all openpaths for path containing this element at time t-1
           id = find(cell2mat(arrayfun( @(x) (x.path(end)==I(i))&&( (x.t_start+length(x.path)-1)  < t), openpaths, 'uniformoutput',false)'));

           if isempty(id)
               newid = length(openpaths)+1;
               openpaths(newid).t_start = t;
               openpaths(newid).path = J(i);
                if t==2,
                    
                    error('Shouldn''t get here...');
                end
           else
                openpaths(id).path = [ openpaths(id).path, J(i) ];
           end
        end
    end   
    
    %Clean up by moving all remaining open paths to close paths
    for p=1:length(openpaths),
        cid = length(closedpaths)+1;
        closedpaths(cid).t_start = openpaths(p).t_start;
        closedpaths(cid).path = openpaths(p).path;
    end 
end