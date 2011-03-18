function new_coords = rescaleImageToPx( imcoords )

new_coords(1,:) = imcoords(1,:).*1000+max(abs(imcoords(1,:)).*1000);
new_coords(2,:) = imcoords(2,:).*1000+max(abs(imcoords(2,:)).*1000);