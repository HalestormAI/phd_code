function [lines,longestLines] = findlines( I1, drawit)

%     I1g = rgb2gray(I1);
    I1g = I1;
    edges = edge(I1g,'canny',[0.04 0.2] );
    [H T R] = hough(edges);
    P  = houghpeaks(H, 50, 'threshold',ceil(0.3*max(H(:))));
    lines = houghlines(edges, T, R, P);
    
    d = zeros(1,length(lines));
    for i=1:length(lines)
        d(i) = vector_dist(lines(i).point1,lines(i).point2);
%         lHom(i) = hcross([lines(i).point1;1],[lines(2).point1;1]);
    end
    
    longestLineIds = find(d > mean(d));
    longestLines = lines(longestLineIds);

    if nargin > 1 && drawit
        figure
        subplot(121);
        imshow(edges)
        subplot(122);
        imshow(I1g), hold on
        for k = 1:length(lines)
            xy = [lines(k).point1; lines(k).point2];
            plot(xy(:,1), xy(:,2), 'g.-', 'LineWidth',2);
        end
        for i = 1:length(longestLineIds)
            k = longestLineIds(i);
            xy = [lines(k).point1; lines(k).point2];
            plot(xy(:,1), xy(:,2), 'r.-', 'LineWidth',2);
        end
    end
end