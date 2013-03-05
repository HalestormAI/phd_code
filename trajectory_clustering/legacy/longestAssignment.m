function trajOut = longestAssignment( trajs, matches )

    lengths = cellfun(@length,trajs);

    trajOut = cell(length(matches),1);
    
    for m=1:length(matches)
        [~,MAXID] = max(lengths(matches{m}));
        trajOut{m} = trajs{matches{m}(MAXID)};
    end
end