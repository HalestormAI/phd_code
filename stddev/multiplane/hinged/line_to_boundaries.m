function lineEnds = line_to_boundaries( linePts, mm )
% Take two end points defining a line and the boundaries of an image (in
% terms of a minmax on all trajectory points). Find the equation of the 
% line using `polyfit` then extend to x-boundaries of the image.

    l2 = polyfit( linePts(1,:), linePts(2,:), 1 );

    lineEnds = NaN*ones(2,2);
    for i=1:2
        lineEnds(1,i) = mm(1,i);
        lineEnds(2,i) = l2(1)*mm(1,i) + l2(2);
    end
end