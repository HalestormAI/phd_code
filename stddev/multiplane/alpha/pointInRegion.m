
    
    function isit = pointInRegion( p, img, img_offset )
        
        p_new = p - img_offset;
        
        isit = logical(img( round(p_new(1)), round(p_new(2)) ));
    end