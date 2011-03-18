function doesntfit = notFit( im_coords, H, x_iter, alpha )

if numel(H) == 4,
    rw_1 = find_real_world_points( im_coords, iter2plane(H) );
else
    rw_1 = H*makeHomogenous( im_coords );
end
im_1 = find_real_world_points( im_coords, iter2plane( x_iter ) );

rw_spds  = speedDistFromCoords( rw_1 );
rw_spds = rw_spds ./ mean(rw_spds);
im_spds  = speedDistFromCoords( im_1 );
im_spds = im_spds ./ mean(im_spds);
doesntfit = kstest2( rw_spds, im_spds, alpha );

% try
%     % Take CDF from rw speeds
%     mycdf = findCDF( rw_spds );
% 
%     % Compare normalised im speeds to CDF using kstest
%     doesntfit = kstest( normaliseSpeeds(im_spds), mycdf, 0.00001 ) == 0;
% catch exception
%    disp( exception.message);
%    error('cdffail')
% end