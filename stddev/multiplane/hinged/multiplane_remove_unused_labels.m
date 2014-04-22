function [new_assignments, new_hypotheses] = multiplane_remove_unused_labels( old_labelling, old_hypotheses )
% Removes any labels that aren't used
% ofteN follows MULTIPLANE_BREAK_SAME_ORIENTATION
%
% Used in MULTIPLANE_MULTICLASS_SVM

    hypoth_ids = 1:size(old_hypotheses,1);
    labels = unique(old_labelling);
    
    unused = sort(setdiff(hypoth_ids, labels),'descend');
    
    new_hypotheses = old_hypotheses;
    new_assignments = old_labelling;
    
    % todo vectorise this
    
    for u=1:length(unused)
        fprintf('To remove: %d (idx: %d). Size of hypotheses: ', unused(u),u);
        new_hypotheses
        size(new_hypotheses)
        new_hypotheses(unused(u),:) = [];
        new_assignments(new_assignments > unused(u)) = new_assignments(new_assignments > unused(u)) - 1;
    end
end