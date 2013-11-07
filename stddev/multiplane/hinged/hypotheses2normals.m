function normals  = hypotheses2normals( hypotheses )
    for h=1:size(hypotheses,1)
        normals{h} = normalFromAngle(hypotheses(h,1), hypotheses(h,2));
    end
end