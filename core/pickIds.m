function [ids_full,usable,im_ids] = pickIds( Ch_norm, imc, DELTA, im )
        [~, ~, lengths, ~, hinfo] = findLengthDist( Ch_norm, 0 );
        [~,maxidx] = max(hinfo.counts);
        big = hinfo.boundaries(maxidx);

        idx_1 = find( and( (lengths >= big - DELTA) , (lengths < big + DELTA) ) );
        full_idx = sort([(2.*idx_1-1),(2.*idx_1-1)+1]);
        usable = imc( :, full_idx );
        
        usable
        
        %ids_full = monteCarloPaths( usable, 3,3,5 );
        if nargin < 4,
            ids_full = smartSelection( usable, 3, 1/3 );
        else
            ids_full = smartSelection( usable, 3, 1/3, im );
        end
        im_ids = full_idx(ids_full);
        
         if nargin >= 4,
            figure,
            imagesc(im);
            drawcoords(imc(:,full_idx) , '', 0, 'b');
            drawcoords(usable(:,ids_full) , '', 0, 'g');
         end
    
        if size(usable,2) < 3,
            err = MException('IJH:USABLE:NOTENOUGH','Conditions to stringent. No Joy Here.');
            throw( err );
        end

%         save important_info ids_full usable full_idx

    end