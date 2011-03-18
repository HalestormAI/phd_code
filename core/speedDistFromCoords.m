function [speeds,f] = speedDistFromCoords( coords, plane )

    speeds = zeros(1,size(coords,2)/2);
    
    for s=1:2:size(coords,2),
        speeds( (s+1) / 2 ) = vector_dist( coords(:,s), coords(:,s+1) );
    end
   
    if nargin ==2,
        f = figure;
        hist( speeds, 10);
        title(sprintf('Speeds given Plane, d: %3f, n=(%4f,%4f,%4f)', plane.d, plane.n(1),plane.n(2), plane.n(3)))
    else
        f = 0;
    end
end