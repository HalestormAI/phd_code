currSub = gca;

newfig = figure;
axis;
copyobj( allchild(currSub), gca);
