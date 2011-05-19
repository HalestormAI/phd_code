imtms=reshape(repmat(im_times./25,2,1),length(im_coords),1);
times = sort(im_times)./25;
F         = moviein(max(times));
for i=1:max(times),
    idxs = find(imtms == i);
    if ~isempty(idxs),
        overlaycoords(im_coords(:,idxs),im1);
    else
        imagesc(im1);
    end
    axis([0   720  0   576]);
    F(:,length(F)+1) = getframe;
    close all;
end

movie(F);