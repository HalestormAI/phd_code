function grp = multiplane_overlay_sliding_regions( regions, labelling )

grp = hggroup;

colours=['k','b','m'];

for r = 1:length(regions)
    circ = filledCircle(regions(r).centre, regions(r).radius, 500, colours(labelling(r)+1));
    set(circ,'EdgeAlpha',0.2);
    set(circ,'FaceAlpha',0.1);
    set(circ,'Parent', grp );
end

axis ij;