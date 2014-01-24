function TF = multiplane_check_adjacency( imgs )

    img_1g = bwmorph(imgs{1},'thicken');
    img_2g = bwmorph(imgs{2},'thicken');
    
    TF = any(any((img_1g+img_2g)>=2));
end