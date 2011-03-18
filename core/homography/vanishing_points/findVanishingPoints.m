function [intersects,l_inf] = findVanishingPoints( parallels,I1 )

% Find intersection points of each pair of parallel lines

%intersects = zeros( 3,size(parallels,1) );
points = zeros( 2,3,2,size(parallels,1) );
figure,
imagesc(I1)
hold on
color = ['b','r'];
for i = 1:size(parallels,1)
    
    intersects{i} = cross( parallels{i}(:,1), parallels{i}(:,2) )
    intersects{i} = intersects{i} ./ intersects{i}(3);
%     
%     drawLine( mat2ln( points(:,:,1,i) ), 'g' );
%     drawLine( mat2ln( points(:,:,2,i) ), 'g' );
 %   intersects(:,i) = line_intersect3( ln1, ln2, pts1(1,:)', pts2(1,:)' );
    scatter( intersects{i}(1,:),intersects{i}(2,:), 'g*' );
end
axis auto
for i=1:2,
    for j=1:2,
        parallels{i}(:,j)
        hline(parallels{i}(:,j),color(i));
    end
end

% Find line between two intersects...
l_inf = cross( intersects{1}, intersects{2} );
hline( l_inf, 'g' );
l_inf = l_inf./ l_inf(3)

P = eye(3);
P(3,:) = l_inf';

%% Now need to use the P matrix to rectify to
%% affine. Then find parallel lines.
P_tform = maketform('affine',P);
P_tform.tdata.T
I2 = imtransform( I1, P_tform);
figure, imagesc(I2);

title('This should be transformed...');
return;
%% Conics - We have 2 pairs of lines, l(1):a,b and l(2):a,b
% % We need at least two conditions to find the intersection of the 
% % Get 1st set of orthagonal lines
% l(1) = struct( ... 
%     'a', cross( pt2homog(parallels(1).start), pt2homog(parallels(1).end)), ...
%     'b', cross( pt2homog(parallels(2).start), pt2homog(parallels(2).end)) );
% 
% l(2) = struct( ... 
%     'a', cross( pt2homog(parallels(3).start), pt2homog(parallels(3).end)), ...
%     'b', cross( pt2homog(parallels(4).start), pt2homog(parallels(4).end)) );
% 
% a(1) = -l(1).a(2) ./ -l(1).a(1)
% a(2) = -l(2).a(2) ./ -l(2).a(1)
% b(1) = -l(1).a(2) ./ -l(1).a(1)
% b(2) = -l(2).a(2) ./ -l(2).a(1)
% 
% c_alpha = (a+b)./2
% c_beta = (a - b)*cot(theta);
%%

% now have vanishing line, need to find vanishing points
% s = 1;
% 
% dx1 = metricLines(1,1) - metricLines(3,1);
% dx2 = metricLines(1,2) - metricLines(3,2);
% 
% dy1 = metricLines(2,1) - metricLines(4,1);
% dy2 = metricLines(2,2) - metricLines(4,2);
% ca = (dx1*dy1 - (s^2)*dx2*dy2) / (dy1^2 - (s^2)*(dy2^2));
% cb = 0;
% 
% r = abs (s * (dx2*dy1 - dx2*dy2) / (dy1-(s^2)*(dy2^2)));
