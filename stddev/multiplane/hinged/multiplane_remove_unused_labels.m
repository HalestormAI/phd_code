function [new_assignments, new_hypotheses] = multiplane_remove_unused_labels( old_labelling, old_hypotheses )
% Removes any labels that aren't used
% ofteN follows MULTIPLANE_BREAK_SAME_ORIENTATION
%
% Used in MULTIPLANE_MULTICLASS_SVM

    hypoth_ids = 1:size(old_hypotheses,1);
    labels = unique(old_labelling);
    
    unused = setdiff(hypoth_ids, labels);
    
    new_hypotheses = old_hypotheses;
    new_assignments = old_labelling;
    
    % todo vectorise this
    for u=1:length(unused)
        new_hypotheses(unused(u),:) = [];
        new_assignments(new_assignments > unused(u)) = new_assignments(new_assignments > unused(u)) - 1;
    end
end