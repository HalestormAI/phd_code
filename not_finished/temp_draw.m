ids = getVectorIds( im_coords, 6);
[fR, x0s, xiters,p] = runWithErrors_sim( im_coords, ids, im1, 100, -1 );

passes = xiters(sum(fR(:,1:4),2) == 0,:)

numu = removeOutliersFromMean(passes,plane.n);

coords_rect = find_real_world_points(im_coords,iter2plane(numu))

mu_l_est = findLengthDist( coords_rect,0 )
mu_l_act = findLengthDist( coords,0 )
l_norm = mu_l_est / mu_l_act
coords_rescale = coords_rect ./ l_norm;
DISP=mean(coords_rescale,2) - mean(coords,2)
coords_trans = cell2mat(cellfun(@(x) x-DISP, num2cell(coords_rescale,1), 'UniformOutput',false))

drawcoords3(coords)
drawcoords3(coords_trans,'',0,'r')