
f = figure;
offset = 0;

NUM_PLANES = length(PLANE_PARAMS);
for i=1:length(PLANE_PARAMS)    
    GT_T	 = PLANE_PARAMS(1,i);
    GT_P     = PLANE_PARAMS(2,i);
    GT_D     = PLANE_PARAMS(3,i);
    GT_ALPHA = PLANE_PARAMS(4,i);

    
    if ~mod(i-1,12) && i > 1 && i <= NUM_PLANES
        saveas(f, sprintf('planes%d.fig',ceil((offset+1)./12)));
        offset = offset + 12;
        f = figure;
    end
    
    subplot(3,4,i-offset);
    drawPlane(all_camPlane{i},'',0,'k');
    cellfun(@(x) drawcoords3(traj2imc(x,1,1), '',0,'r'),all_camTraj{1,i});

    
end