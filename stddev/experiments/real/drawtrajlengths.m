
for i=1:length(gt_trajLengths)
figure;
    mgt = mean(gt_trajLengths{i});
    met = mean(est_trajLengths{i});
    
    ratio = mgt / met;
    
    subplot(3,1,[1,2])
    bar([ gt_trajLengths{i}/ratio; est_trajLengths{i}]','BarWidth',1);
    subplot(3,1,3);
    drawtraj(plane_details.trajectories{i},'',0);
    axis image;
    saveas(gcf,sprintf('length_comparison_%d.fig',i));
end