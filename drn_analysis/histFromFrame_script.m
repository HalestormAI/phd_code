% f = figure;
% imagesc(im1);
% axis equal;
% axis([0 size(im1,2) 0 size(im1,1) ]);
% 
% hold on
% M = size(im1,1);
% N = size(im1,2);
% %% Draw Grid
% for k = 1:ceil(M/size(bins,1)):M
%     x = [1 N];
%     y = [k k];
%     plot(x,y,'Color','w','LineStyle','-');
%     plot(x,y,'Color','k','LineStyle',':');
% end
% 
% for k = 1:ceil(N/size(bins,2)):N
%     x = [k k];
%     y = [1 M];
%     plot(x,y,'Color','w','LineStyle','-');
%     plot(x,y,'Color','k','LineStyle',':');
% end
% 
% hold off
if ~exist('f'),
    f = gcf;
end
clear sf;
%% Get histogram for each block clicked on
while 1,
    if exist('sf','var'),
        close(sf);
    end
    figure(f);
    [px,py,btn]=ginput(1);
    if btn == 3,
        break;
    else
        pos = [px,py];
        binidx = ceil(pos ./ binsz);

%         sf = getBinHistogram(bins,binidx(1),binidx(2));
        sf= figure;
        
        % Find index in terms of all bins
        allbinsidx = intersect(find(positions(:,1) == binidx(2)), find(positions(:,2) == binidx(1)) );
        
        % Now find cluster from `idx'
        clust = centres(idxs(allbinsidx),:);
        col = colours(idxs(allbinsidx),:);
        bar(1:8,clust);
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor',col )
        
        pause
    end
end