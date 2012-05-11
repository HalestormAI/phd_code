function ids = subsampleByDrn( directions, NUM_NEEDED )

if nargin < 2,
    NUM_NEEDED = 100;
end

if length(directions) <= NUM_NEEDED
    ids = 1:length(directions);
    disp('Num. trajectories <= number requested.');
    return;
end

[group_freq, group_ids] = histc( directions,0:36:360 );


per_bin_ideal = ceil(NUM_NEEDED./length(find(group_freq)));

unused_groups = 1:length(group_freq);

ids = [ ];
counter = 0;
while length(ids) < NUM_NEEDED
    autofill_ids = find(group_freq(unused_groups) <= per_bin_ideal);
    
    if isempty(autofill_ids)
        % If all the current groups have enough to put our desired
        % trajectories in, do random selection from each group.
        for i=1:length(unused_groups)
            g = find(group_ids == unused_groups(i));
            rids = randperm(length(g));
            
            % Need a check to make sure we're not going to overfill
            if (length(ids) + per_bin_ideal) > NUM_NEEDED
                per_bin_ideal = NUM_NEEDED - length(ids);
            end
            ids = [ids; g(rids(1:per_bin_ideal)) ];
        end
        
        break;
    else
        % This is emptying all the groups with < desired number of
        % trajectories into the ids list.
        unused_groups(ismember(unused_groups,unused_groups( autofill_ids ))) = [];
        
        ids = [ids find(ismember(group_ids,autofill_ids))];
        stilltofind = NUM_NEEDED - length(ids);
        per_bin_ideal = ceil(stilltofind./length(unused_groups));
    end
    
end

if size(ids,1) > 1 && size(ids,2) > 1
    ids = reshape(ids, numel(ids), 1);
end