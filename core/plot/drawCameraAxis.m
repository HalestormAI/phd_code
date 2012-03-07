function drawCameraAxis( scale,newfig )
    
    if nargin < 1 || isempty(scale)
        scale = 1;
    end
    if nargin == 2 && newfig;
        figure;
    end

    origin = [0 0 0];
    
    lim =  scale * [ 1  0  0;
                     0  1  0;
                     0  0 -1];
                 
    textLabels = {'X_c','Y_c','Z_c'}

    for i=1:3
        vector_dist(origin, lim(i,:))
        vectarrow( origin,lim(i,:) );
        
        textpos = lim(i,:).*0.5+scale/20;
        text(textpos(1), textpos(2), textpos(3),strcat('\color{blue} ', textLabels{i}))
        hold on;
    end
    
end