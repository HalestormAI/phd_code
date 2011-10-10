function rect_coords = rectifyClusteredTracklets( im_coords, L_t, kcntrs, planes )

% IN L_t, PLANE 1 is INDEX 2, etc SINCE NO-ASSIGNMENT IS INDEX 1.
figure;
colours = ['b','r','g'];
for p=1:length(planes),
    
    % First, get set of im_coords for plane.
    lbl_idx = find( L_t == p+1 )';
    im_idx = sort([2*lbl_idx-1,2*lbl_idx]);
    kcntrs(p,:)
    finalTry( planes(p), iter2plane( kcntrs(p,:) ), im_coords(:,im_idx), 20);
end

    

end