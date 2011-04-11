function doesntfit = notFit( im_coords, H, plane, alpha )

if numel(H) == 4,
    % H is actually a NORMAL
    rw_1 = find_real_world_points( im_coords, iter2plane(H) );
else
    rw_1 = H*makeHomogenous( im_coords );
end

im_1 = find_real_world_points( im_coords, plane );

rw_spds  = speedDistFromCoords( rw_1 );
rw_spds = rw_spds ./ mean(rw_spds);
im_spds  = speedDistFromCoords( im_1 );
im_spds = im_spds ./ mean(im_spds);
try
    doesntfit = kstest2( rw_spds, im_spds, alpha );
catch err,
    if strcmp(err.identifier,'MATLAB:histc:InvalidInput'),
        doesntfit = 1;
        rethrow(err);
    end
end
    
