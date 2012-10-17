function img = multiplane_pixels_for_region( img_offset, region, img )

    mins = round(region.centre - region.radius - img_offset);
    maxs = round(region.centre + region.radius - img_offset);
    
    img( (mins(1):maxs(1)), (mins(2):maxs(2)) ) = 1;
end