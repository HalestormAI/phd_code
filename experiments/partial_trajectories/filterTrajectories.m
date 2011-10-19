function [acceptable,v_dists] = filterPaths( im_usable, THRESHOLD, MIN_LENGTH )

    if nargin == 1,
        THRESHOLD = 30;
    end
    
    v_dists = {};
    acceptable = {};
    
    for p = 1:length(im_usable),
        endpointDists = vector_dist( im_usable{p}(:,2:end-1) )
        if ~isempty(find(endpointDists > THRESHOLD,1))
            vecParts = SplitVec(endpointDists > THRESHOLD);
            vecParts{1}
            
            [cIds,vIds] = getIdsForParts( vecParts );
            
            nz = cellfun( @(x) sum(x) == 0, vecParts )
            
            consec_cIds = cIds(nz)
            consec_vIds = vIds(nz)
            
            lengths = cellfun(@length, consec_cIds);
            
            new_cIds = consec_cIds( (lengths > (MIN_LENGTH-1)) );
            new_vIds = consec_vIds( (lengths > (MIN_LENGTH-1)) );
            
            if ~isempty(new_vIds),
                for j = 1:length(new_vIds),
                    n = new_vIds{j}
                    im_usable{p}(:,n)
                    acceptable{end+1} = im_usable{p}(:,n);
                    v_dists{end+1} = endpointDists(new_cIds{j})
                end
            else
                fprintf('Getting rid of %d\n', p);
            end
        else
            acceptable{end+1} = im_usable{p};
            v_dists{end+1} = endpointDists;
            disp('this is probably rare');
        end
        
    end
    
    
end
