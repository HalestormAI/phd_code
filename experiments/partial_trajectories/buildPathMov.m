
clear MOV

figure;
for tt = 2:max(pathtimes+pathlengths),
    imagesc(im1);
%     pause
    % Run from t=1 to last item (may not be the last recorded pathtime...)
    for t=tt-1:tt
        try
            ids = intersect(find(pathtimes <= t), find( (pathtimes + (pathlengths-1)) >= t));

            pathcell = {paths{ids}}';
            path_starts = pathtimes(ids);
            C_t = [];
            for i=1:size(pathcell,1), 
                thistimepathcell = pathcell{i}(t-path_starts(i)+1);
                thistimepathcellcids = mpid2cid(thistimepathcell);

                thisC_times = C_TIMES{t};
                C_t{i} = thisC_times(:,thistimepathcellcids);
            end
            drawcoords(cell2mat(C_t),'',0,'b');
            MOV(tt-1) = getframe;
        catch err,
            t
            size(C_t)
            size(C_TIMES{t})
            rethrow(err);
        end
    end
end