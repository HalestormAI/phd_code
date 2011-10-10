function drawBoundingBox(corners, colour)

    if nargin < 2,
        colour = 'b';
    end

    corners(:,end+1) = corners(:,1);
    if size(corners,1) == 2,
        plot(corners(1,:),corners(2,:), colour);
    else
        plot3(corners(1,:),corners(2,:), corners(3,:), colour);
    end