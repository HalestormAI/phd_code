function [idx, idx_sub] = findMoreVerticalComponents( imc, im_ids, im )

%% Find horizontal and vertical components of vector
        
        % Get the horz and vert coords
        imc_h = imc(1, im_ids);
        imc_v = imc(2, im_ids);
        
        % Reshape
        imc_hh = reshape(imc_h,2,length(imc_h)/2)';
        imc_vv = reshape(imc_v,2,length(imc_v)/2)';
        
        % Get components;
        comp_h = imc_hh(:,1) - imc_hh(:,2);
        comp_v = imc_vv(:,1) - imc_vv(:,2);
        
        gttest = abs(comp_v) >= abs(comp_h);
        % Pick those with larger vertical than horizontal component
        idx_sub_mp = find( gttest )';
        
        idx_sub = sort([(2.*idx_sub_mp-1),(2.*idx_sub_mp-1)+1]);
        
        idx = im_ids( idx_sub );
        
        if nargin >= 3,
            overlaycoords(imc( :, im_ids), im );
            drawcoords( imc(:, idx), '', 0, 'r' );
        end
end