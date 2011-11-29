function [acceptable,v_dists,in_idsp,in_idsv] = filterTrajectories( im_usable, MIN_SPEED, VECTOR_LENGTH )

    if nargin < 2,
        MIN_SPEED = 10;
    end
    if nargin < 3,
        VECTOR_LENGTH = 4;
    end
    
    v_dists = {};
    acceptable = {};
    in_idsp = {};
    in_idsv = {};
    
    traj_ls = cellfun( @vector_dist, im_usable, 'uniformoutput',false);
    
    for p = 1:length(im_usable),
        traj_l = traj_ls{p};
        % If there are vectors of < minimum length, we need to split the
        % set. Otherwise move the whole set into the new cell array.
        if ~isempty(find(traj_l < MIN_SPEED,1))
            
            % Split into consecutive parts
            vecParts = SplitVec(traj_l < MIN_SPEED);
            
            for v=1:length(vecParts), 
                % ids start at <num_pieces_before>+1
                % Cids is the id of the vector
                cIds{v} = length(cell2mat(vecParts(1:v-1))) + (1:length(vecParts{v}));
                % vids is the id of the endpoints of the vector
                vIds{v} = mpid2cid( cIds{v} );
            end
            
            % Only want the partsfor which traj_l > MIN_SPEED
            nz = cellfun( @(x) sum(x) == 0, vecParts );
            
            consec_cIds = cIds(nz);
            consec_vIds = vIds(nz);
            
            lengths = cellfun(@length, consec_cIds);
            
            new_cIds = consec_cIds( (lengths >= (VECTOR_LENGTH)) );
            new_vIds = consec_vIds( (lengths >= (VECTOR_LENGTH)) );
            
            if ~isempty(new_vIds),
                for j = 1:length(new_vIds),
                    n = new_vIds{j};
%                     im_usable{p}(:,n);
                    acceptable{end+1} = im_usable{p}(:,n);
                    v_dists{end+1} = traj_l(new_cIds{j});
                    in_idsp{end+1} = p;
                    in_idsv{end+1} = n;
                end
            end
        else
            
            if( length(im_usable{p})/2 >= VECTOR_LENGTH )
                acceptable{end+1} = im_usable{p};
                v_dists{end+1} = traj_l;
                in_idsp{end+1} = p;
                in_idsv{end+1} = 1:length(im_usable{p});
            end
        end
        
    end
    
    
end
