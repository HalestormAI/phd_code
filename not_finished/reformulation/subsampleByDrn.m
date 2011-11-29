function ids = subsampleByDrn( directions, NUM_NEEDED )

if nargin < 2,
    NUM_NEEDED = 100;
end

if length(directions) <= NUM_NEEDED
    ids = 1:length(directions);
    disp('Num. trajectories <= number requested.');
end

[group_freq, group_ids] = histc( directions,0:36:360 );

per_bin_ideal = ceil(NUM_NEEDED./length(group_freq));

unused_groups = 1:length(group_freq);

ids = [ ];
counter = 0;
while length(ids) < NUM_NEEDED
    autofill_ids = find(group_freq(unused_groups) < per_bin_ideal)
    
    if isempty(autofill_ids)
        for i=1:length(unused_groups)
            g = find(group_ids == unused_groups(i));
            rids = randperm(length(g));
            ids = [ids, g(rids(1:per_bin_ideal)) ];
        end
        break;
    else

        unused_groups(ismember(unused_groups,unused_groups( autofill_ids ))) = [];
        
        ids = [ids find(ismember(group_ids,autofill_ids))];
        stilltofind = NUM_NEEDED - length(ids);
        per_bin_ideal = ceil(stilltofind./length(unused_groups));


    end
    
end