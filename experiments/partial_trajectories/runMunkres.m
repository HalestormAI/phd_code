
%% Prepare time-ordered vectors
TIMES = sort(unique(im_times));
for t=1:length(TIMES),
    C_TIMES{t} = im_coords(:,mpid2cid(find(im_times == TIMES(t))));
end
for t = 2:length(TIMES)
    costMat = buildMunkresCost( C_TIMES{t-1}, C_TIMES{t}, 0.9 );
    [ASSIGN{t},COST{t}] = munkres( costMat );
end
%% Run Munkres for t=(1,2)


% [I,J] = ind2sub(size(ASSIGN),find(ASSIGN));
%% Plot it
% drawcoords( C_TIMES{1}(:,mpid2cid(I)),'',1,'b' );
% axis ij
% drawcoords( C_TIMES{2}(:,mpid2cid(J)),'',0,'r' );
% for i=1:length(I)
%     idxi = mpid2cid(I(i));
%     idxj = mpid2cid(J(i));
%     plot( [C_TIMES{1}(1,idxi(2));C_TIMES{2}(1,idxj(1));], [C_TIMES{1}(2,idxi(2));C_TIMES{2}(2,idxj(1));], 'o-k' );
% end