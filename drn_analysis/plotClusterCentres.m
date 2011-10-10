function f = plotClusterCentres(allbins, positions, colours, idxs, binsz, im1)
    f =figure;
    hold on
    axis ij
    img = imagesc(im1);
    for i = 1:length(allbins),
        pos    = (positions(i,:) - 1) .* binsz;
        colour = colours(idxs(i),:);
        rectangle('Position',[ pos(2), pos(1), 32, 32], 'FaceColor', colour, 'EdgeColor', colour);
    end
    img = imagesc(im1);
    alpha(img,.4)
    axis([0, size(im1,2), 0 size(im1,1)])

end