% bestEstimates = cellfun( @(x) findBestEstimate(x,im_coords), filteredEstimates, 'uniformoutput', false )';
% boxes = buildPathBoundingBoxes(filteredPaths);
% 


% baddist = find(cellfun( @(x) ~((mean(x)+40*std(LENGTHS{i})) > max(x)), LENGTHS )');
% 
% wc = cell(length(filteredPaths),1);
% figure;
% grid on;
% hold on;
% for i=1:length(filteredPaths)
%     if ~any(i==baddist),
%         wc{i} = find_real_world_points( boxes{i}, iter2plane(bestEstimates{i}) );
%         drawBoundingBox(wc{i});
%     end
% end


% figure;
% imagesc(im1);
% hold on;
% for i=1:length(filteredPaths)
%     if ~any(i==baddist),
%         drawBoundingBox(boxes{i},'w');
% %         drawcoords(filteredPaths{i},'',0,'b');
% %         scatter(filteredPaths{i}(1,1),filteredPaths{i}(2,1),24,'g');
% %         drawcoords(filteredPaths{i}(:,2:end-1),'',0,'r');
%     end
% end
% 
% 

figure;
imagesc(im1);
hold on;
for i=1:length(baddist)
    
    drawcoords(filteredPaths{baddist(i)},'',0,'b');
    scatter(filteredPaths{baddist(i)}(1,1),filteredPaths{baddist(i)}(2,1),24,'g');
    drawcoords(filteredPaths{baddist(i)}(:,2:end-1),'',0,'r');
end

