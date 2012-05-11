% Load in image, convert to grey and equalise histogram
I1 = imread('/home/cserv2_a/soc_ug/sc06ijh/PhD/year3/bgsub_frames/cap1-soc_carpark_bgframe.jpg');
I1g = rgb2gray(I1);
I1ge = histeq(I1g);

% Get image size to reposition image centre to (0,0)
im_sz = size( I1 );
im_sz = im_sz(2:-1:1)';
translation = im_sz ./ 2;
imPos = [ [0;0] im_sz ] - repmat(translation,1,2)

% Find lines (canny, hough)
[~,lines] = findlines( I1ge, 1 );

figure;hist(vertcat(lines.theta),18);


% This is a cludge that only works when we have exactly 2 principle directions
done = 0;
centres = gmeans(vertcat(lines.theta));
K = length(centres)

while ~done
    try
        labels = kmeans(vertcat(lines.theta),K);
        done = 1;
    catch err
        disp('KMeans failed this time');
    end 
end

colours = ['r','b'];
figure;
image(I1);
hold on;
axis image;
% Build cell of lines, indexed by direction
homoglines = cell(2,1);
intersects = cell(2,1);
for l=1:2
    lines_sub = lines(labels == l);
    
    homoglines{l} = zeros(3,length(lines_sub));
    
    for k = 1:length(lines_sub)
        homoglines{l}(:,k) = hcross([lines_sub(k).point1,1]',[lines_sub(k).point2,1]');
    end
    
    % Now find all intersections for parallel lines
    inum = 1;
    for i=1:size(homoglines{l},2)-1,
        for j=(i+1):size(homoglines{l},2),
            intersects{l}(:,inum) = hcross( homoglines{l}(:,i), homoglines{l}(:,j) );
            inum = inum + 1;
        end
    end
    scatter(intersects{l}(1,:), intersects{l}(2,:),24,strcat(colours(l),'o'));
end
axis auto;
axis equal;

for l=1:2
    lines_sub = lines(labels == l);
    for k = 1:length(lines_sub)
        hline2( homoglines{l}(:,k), colours(l) );
    end
end
hold off;