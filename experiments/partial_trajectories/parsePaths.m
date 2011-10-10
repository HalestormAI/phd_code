% 
% pathlengths = zeros(length(closedpaths),1);
% pathtimes   = zeros(length(closedpaths),1);
% paths       = cell(length(closedpaths),1);

paths = {};
pathtimes = [];
pathlengths = [];
% 
% 
for p=1:length(closedpaths),
    if ~isempty(closedpaths(p).t_start)
        paths{end+1} = closedpaths(p).path;
        pathtimes(end+1) = closedpaths(p).t_start;
        pathlengths(end+1) = length(closedpaths(p).path);
    end
end
% 
% [~,MAXLENGTH] = max(pathlengths);
% 
% figure;
% imagesc(im1);
% for i=1:pathlengths(MAXLENGTH)
%     t = pathtimes(MAXLENGTH);
%     ids = mpid2cid(paths{MAXLENGTH}(i));
%     cdraw =  C_TIMES{t}(:,ids);
%     drawcoords( cdraw, '',0,'b' );
%     MOV(i) = getframe;
% end

figure;
imagesc(im1);

% Run from t=1 to last item (may not be the last recorded pathtime...)
% for t=1:max(pathtimes+pathlengths)
%     ids = intersect(find(pathtimes <= t), find( (pathtimes + pathlengths) >= t));
%     
%     pathcell = {paths{ids}}';
%     
%     for i=1:size(pathcell,1), 
%         thispathcell = pathcell(i);
%         thistimepathcell = thispathcell{i}(t);
%         thistimepathcellcids = mpid2cid(thistimepathcell)
%         
%         thisC_times = C_TIMES{t};
%         C_t{i} = thisC_times(:,thistimepathcellcids);
%     end
%     try
%         drawcoords(cell2mat(C_t),'',0,'b')
%     catch err,
%         t
%         size(C_t)
%         size(C_TIMES{t})
%         rethrow(err);
%     end
%     MOV(i) = getframe;
% end
