function angles = hinged_initial_condition( hypotheses, plane_graph )
    normals = hypotheses2normals(hypotheses);
    
%     for i=1:(length(normals)-1)
    for i=2:length(plane_graph)
        
        j = plane_graph(i);
        [i,j]
        dotangle = acosd(dot(normals{i}, normals{j}));
        
        if dotangle == 0
            angles(i) = 0;
            continue;
        end
        % now need directionality - compare cross(N1,N2) with vertical
        d = dot(cross(normals{i},normals{j}),[0 0 -1]);
        
        sign = -d./abs(d);
        angles(i-1) = sign*dotangle
    end
    
end