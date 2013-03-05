function trajOut = medianAssignment( trajs, matches, assignment )

    lengths = cellfun(@length,trajs);
    max_length = max(lengths);

    pairs    = cell(length(matches),1);
    startend = cell(length(matches),1);
    
    for m=1:length(matches)
        pairs{m} = nchoosek(matches{m},2);
        startend{m} = cell2mat(cellfun(@(x) [find(assignment{x(1),x(2)},1,'first'),find(assignment{x(1),x(2)},1,'last')],num2cell(pairs{m},2),'un',0));    
    end
    
    
    trajOut = cell(length(matches),1);
    
    for t=1:max_length
        for m=1:length(matches) % For each set
            xs_t = [];
            ys_t = [];
            % Trajectory pair ids for time 
            pairs_t_ids = find(and(t >= startend{m}(:,1), t <=startend{m}(:,2)));
            
            for p = 1:size(pairs_t_ids,1)
                % Get time offset by starttime
                start_t = startend{m}(pairs_t_ids(p),1);
                pr = pairs{m}(pairs_t_ids(p));
                t_offset = t-(start_t-1);
                xs_t = [xs_t,trajs{pr}(1,t_offset)];
                ys_t = [ys_t,trajs{pr}(2,t_offset)];
            end
            
            trajOut{m}(:,t) = [median(xs_t);median(ys_t)];
        end
    end
end
