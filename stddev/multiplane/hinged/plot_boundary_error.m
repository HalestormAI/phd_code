% rawCostVector = labelCost(sub2ind(size(labelCost), labelling_prealpha, 1:length(labelling_prealpha)))
rawCostVector([regions(:).empty]) = 0
centres = [regions(:).centre]
X = centres(1,:)
Y = centres(2,:)
figure;
scatter3(X,Y,rawCostVector, 25,255.*rawCostVector./max(rawCostVector),'o','filled')
drawPlanes(planes)