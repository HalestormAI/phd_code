function angles = hinged_initial_condition( hypotheses )
    normals = hypotheses2normals(hypotheses);
    
    for i=1:(length(normals)-1)
        dotangle = acosd(dot(normals{i}, normals{i+1}));
        
        % now need directionality - compare cross(N1,N2) with vertical
        d = dot(cross(normals{i},normals{i+1}),[0 0 -1]);
        sign = -d./abs(d);
        angles(i) = sign*dotangle;
    end
    
end