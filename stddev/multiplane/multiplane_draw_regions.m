function f = multiplane_draw_regions( regions, newfig, colours, traj )

    if nargin < 2
        newfig = 1;
    end

    if nargin < 3 || isempty(colours)
        colours = ['b','g','r','y','m','c'];
    end
    
    if length(regions) > length(colours)
        colours = repmat(colours,1,ceil(length(regions)/length(colours)));
        
        
%         error('Too many regions for the defined number of colours. Specify more!');
    end
    
    if newfig
        f = figure;
    else
        f = gcf;
        hold on;
    end
    
    centres = [regions.centre];
    gscatter(centres(1,:),centres(2,:),1:length(centres),colours(1:length(centres)),'*',12,'off');

    for r=1:length(regions)
        if nargin >= 4 && ~isempty(traj)
            rtraj = multiplane_trajectories_for_region(traj,regions(r));
            drawtraj(rtraj,'',0,colours(r),3,'-.');
        end
        pos = regions(r).centre' - regions(r).radius;
        rectangle('Curvature',[1 1],'Position', [pos,regions(1).radius*2, regions(1).radius*2],'EdgeColor',colours(r));
    end        
       
    view(0,90);
    
        

end