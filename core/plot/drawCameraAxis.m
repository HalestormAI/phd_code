function drawCameraAxis( scale,rotation, newfig )
    
    if nargin < 1 || isempty(scale)
        scale = 1;
    end
    
    if nargin < 2 || isempty(rotation)
        rotate = eye(3);
    else
        rotatex = makehgtform('xrotate', -rotation(1) );
        rotatez = makehgtform('zrotate', -rotation(2) );
        rotatex = rotatex(1:3,1:3);
        rotatez = rotatez(1:3,1:3);
        rotate = rotatez*rotatex;
    end
    if nargin == 3 && newfig;
        figure;
    end

    origin = [0 0 0];
    
    
    lim = rotate * scale * [ 1  0  0;
                             0  1  0;
                             0  0 -1];
                 
    textLabels = {'X_c','Y_c','Z_c'};

    for i=1:3
        vector_dist(origin, lim(i,:))
        vectarrow( origin,lim(i,:) );
        
        textpos = lim(i,:).*0.5+scale/20;
        text(textpos(1), textpos(2), textpos(3),strcat('', textLabels{i}))
        hold on;
    end
    
end