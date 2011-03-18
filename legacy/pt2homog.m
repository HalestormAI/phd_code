function pt = pt2homog( pt )

if (iscol(pt) && size(pt,1) < 3) || isrow(pt) && size(pt,2) < 3,
    pt(3) = 1;
end