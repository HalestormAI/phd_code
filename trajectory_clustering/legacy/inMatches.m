function idx = inMatches( i, matches )
    if numel(i) > 1
        idx = arrayfun(@(x) inMatches(x,matches), i );
        return;
    end
    for m=1:length(matches)
        if ismember(i,matches{m})
            idx = m;
            return;
        end
    end
    idx = 0;
end