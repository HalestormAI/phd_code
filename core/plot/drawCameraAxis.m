function camgroup = drawCameraAxis( scale,rotation, newfig, origin )
    
    if nargin < 1 || isempty(scale)
        scale = 1;
    end
    
    if nargin < 2 || isempty(rotation)
        rotate = eye(3);
    else
        rotatex = makehgtform('xrotate', -rotation(2) );
        rotatez = makehgtform('zrotate', -rotation(1) );
        rotatex = rotatex(1:3,1:3);
        rotatez = rotatez(1:3,1:3);
        rotate = rotatez*rotatex;
    end
    if nargin >= 3 && newfig;
        figure;
    end

    if nargin < 4 || isempty(origin)
        origin = [0 0 0];
    end
    
    
    lim = rotate * scale * [ 1  0  0;
                             0  1  0;
                             0  0 -1];
                 
    textLabels = {'X_c','Y_c','Z_c'};

    for i=1:3
        lineHandles(i) = vectarrow( origin,lim(i,:)+origin );
        
        textpos = (lim(i,:)+scale/20)+origin;
        textHandles(i) = text(textpos(1), textpos(2), textpos(3),strcat('', textLabels{i}),'Color',[0 0 1]);
        hold on;
    end
    
    for h=1:length(lineHandles)
        set(get(lineHandles(h),'children'),'LineWidth',1);
    end
    camgroup = hggroup;
    set([lineHandles,textHandles],'Parent',camgroup);
    
end