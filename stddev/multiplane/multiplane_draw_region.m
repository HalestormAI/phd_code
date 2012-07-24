function f = multiplane_draw_region( region, newfig, colour )

    if nargin < 2
        newfig = 1;
    end

    if nargin < 3 || isempty(colour)
        colours = 'b';
    end
       
    if newfig
        f = figure;
    else
        f = gcf;
        hold on;
    end
    
    scatter(region.centre(1,:),region.centre(2,:),12,strcat(colour,'*'));
    drawtraj(region.traj,'',0,colour,2,'-');
    pos = region.centre' - region.radius;
    rectangle('Curvature',[1 1],'Position', [pos,region.radius*2, region.radius*2],'EdgeColor',colour);     
       
    view(0,90);
    
        

end