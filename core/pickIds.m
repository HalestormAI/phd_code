function [ids_full,usable,im_ids] = pickIds( Ch_norm, imc, DELTA, im )
        [~, ~, lengths, ~, hinfo] = findLengthDist( Ch_norm, 0 );
        [~,maxidx] = max(hinfo.counts);
        big = hinfo.boundaries(maxidx);

        idx_1 = find( and( (lengths >= big - DELTA) , (lengths < big + DELTA) ) );
        full_idx = sort([(2.*idx_1-1),(2.*idx_1-1)+1]);
        usable = imc( :, full_idx );
        
        if nargin < 4,
            [vert_ids, vert_sub] = findMoreVerticalComponents( imc, full_idx );
        else
            [vert_ids, vert_sub] = findMoreVerticalComponents( imc, full_idx );
        end
        
        more_usable = imc(:, vert_ids );
        
        %% Now make final selection
        
        %ids_full = monteCarloPaths( usable, 3,3,5 );
        if nargin < 4,
            ids_sub = smartSelection( more_usable, 3, 1/3 );
        else
            ids_sub = smartSelection( more_usable, 3, 1/3, im );
        end
        
        ids_full = (vert_sub(ids_sub));
        im_ids = vert_ids(ids_sub);
        
        %% Draw them
        
         if nargin >= 4,
            figure,
            imagesc(im);
            drawcoords(imc(:,full_idx) , '', 0, 'k');
            drawcoords(imc(:,vert_ids) , '', 0, 'b');
            drawcoords(usable(:,ids_full) , '', 0, 'g');
         end
    
        if size(usable,2) < 3,
            err = MException('IJH:USABLE:NOTENOUGH','Conditions to stringent. No Joy Here.');
            throw( err );
        end

        
%         save important_info ids_full usable full_idx

    end