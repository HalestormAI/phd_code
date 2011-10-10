drawSimPlanes(planes,[],colours,'im'); 
labels = unique(labelling);
for l=1:length(labels),
    idxs = ( find(labelling==labels(l)) );
    %drawcoords(im_coords(:,idxs),'',0,colours(labels(l)));
    scatter(midpoints(1,idxs),midpoints(2,idxs),strcat(colours(labels(l)),'*'));

end