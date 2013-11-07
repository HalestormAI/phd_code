% rawCostVector = labelCost(sub2ind(size(labelCost), labelling_prealpha, 1:length(labelling_prealpha)))
rawCostVector([regions(:).empty]) = 0
centres = [regions(:).centre]
X = centres(1,:)
Y = centres(2,:)
figure;
% subplot(1,2,1)
% scatter3(X,Y,rawCostVector, 25,255.*rawCostVector./max(rawCostVector),'o','filled')
drawPlanes(planes)

cmap = colormap(jet(256));

grp = hggroup;

colorpos = round(rawCostVector./max(rawCostVector).*255)+1;


for r = 1:length(regions)
    circ = filledCircle(regions(r).centre, regions(r).radius, 500, cmap(colorpos(r),:));
    set(circ,'EdgeAlpha',0.2);
    set(circ,'FaceAlpha',0.1);
    set(circ,'Parent', grp );
end

% subplot(1,2,2)
% X = centres(1,:);
% Y = centres(2,:);
% surf(X,Y,diag(rawCostVector));
% 
% 
