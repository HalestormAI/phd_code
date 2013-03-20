
    
    function mean_distance = assigment_distance( ass , distances )
        subs = [1:length(ass);ass']'; % Get the subscript indices
        subs(~subs(:,2),:) = []; % remove all where a vertex doesn't match
        idx = sub2ind(size(distances), subs(subs(:,2)>0,1), subs(subs(:,2)>0,2));
        mean_distance = mean(distances(idx));
    end