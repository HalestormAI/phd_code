function nuim = useCentralCoords( im_coords, im1 )
rng = [ 175,0;675,425];

good_ids1=intersect (find( im_coords(1,:) < rng(2,1) ), find( im_coords(1,:) > rng(1,1)));
good_ids2=intersect (find( im_coords(2,:) < rng(2,2) ), find( im_coords(2,:) > rng(1,2)));

good_ids = intersect(good_ids1,good_ids2);


odds = good_ids( find( mod(good_ids,2)==1 ) );
ids = sort( [odds,odds+1] );
imagesc( im1 )
nuim = im_coords(:,ids);
drawcoords(nuim,'',0,'b')