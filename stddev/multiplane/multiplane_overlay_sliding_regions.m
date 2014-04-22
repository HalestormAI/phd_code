function [grp,regions] = multiplane_overlay_sliding_regions( regions, labelling, colours )

grp = hggroup;

if ~ishold
    hold on
end

labels = unique(labelling);

if nargin < 3 || isempty(colours)

    if nargin < 3 
        colours=['b','m','g','y','c'];
    end
    if length(labels) > length(colours)
        l = linspace(0,1,length(labels)-1);
        colours = [0,l;
                   0,l([floor(length(labels)/3)+1:end,1:floor(length(labels)/3)]);
                   0,l([floor(length(labels)/3)*2+1:end,1:floor(length(labels)/3)*2])]
    end
end
for r = 1:length(regions)
    
    if regions(r).empty 
        colour = 'k';
    else
        colour = colours(:,find(labels==labelling(r),1,'first'))';
    end
    
    circ = filledCircle(regions(r).centre, regions(r).radius, 500, colour);
    set(circ,'EdgeAlpha',0.2);
    set(circ,'FaceAlpha',0.1);
    set(circ,'Parent', grp );
    
    regions(r).handle = circ;
end

view(0,90);
axis equal;
axis ij;