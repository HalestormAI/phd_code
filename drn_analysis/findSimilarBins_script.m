% allbins = zeros( size(bins,1)*size(bins,2),8 );
% positions = zeros( size(bins,1)*size(bins,2),2);
% count = 1;
% for i=1:size(bins,1),
%     for j=1:size(bins,2),
% %         b = rotateHistogram( reshape(bins(i,j,:),1,8) );
%         b = reshape(bins(i,j,:),1,8);
%         
% %         if sum(b) > 0,
% %             allbins(count,:) = b./max(b);
% %         else
%             allbins(count,:) = b;
% %         end
%         positions(count,:) = [i,j];
%         count = count + 1;
%     end
% end
txt = textread('bins.txt', '%s', 'delimiter','\n','whitespace','');
allbins = zeros(size(txt,1),8);
positions = zeros(size(txt,1),2);
for i=1:length(txt),
    [~,SPLIT] = regexp(txt{i},'\d+','split','match');
    LINE = cellfun(@(x) str2double(x),SPLIT);
    allbins(i,:) = rotateHistogram( LINE(3:end) );
    positions(i,:) = LINE(2:-1:1);
end


% To normalise to between 0 and 1
allbins = cell2mat(cellfun(@(x) x ./ max([x,1]), num2cell(allbins,2), 'UniformOutput',false));

centres = gmeans(allbins,0.0001);
numcntrs = size(centres,1);
idxs = zeros(1,length(allbins));
for b=1:length(allbins),
    dists = zeros(numcntrs,1);
    for c=1:size(centres,1),
        dists(c) = vector_dist(allbins(b,:), centres(c,:));
    end
    [~,idxs(b)] = min(dists);
end

% [idxs,centres] = kmeans(allbins,numcntrs,'EmptyAction','drop');

% split = ceil(numcntrs / 3)


colours = rand(numcntrs,3);

plotClusterCentres(allbins, positions, colours, idxs, binsz, im1);
    
    