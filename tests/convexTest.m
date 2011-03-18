function convexTest(number_points)


[~, ~, C_im] = make_test_data( 120, 50, 1, 0.05, number_points );

midpoints = (C_im(:,1:2:size(C_im,2)) + C_im(:,2:2:size(C_im,2))) ./ 2;
hullPoints = convhull(midpoints(1,:)',midpoints(2,:)');

nonConvexMidpointIds = setxor(1:size(midpoints,2), hullPoints);

nonConvexMidpoints = midpoints( :, nonConvexMidpointIds );

hullPoints2 = convhull(nonConvexMidpoints(1,:)',nonConvexMidpoints(2,:)');
% need to get hullPoints2 in terms of midpoints instead of
% nonConvexMidpoints
%   midpoints(:,nonConvexMidpointIds( hullPoints2 ));



drawcoords( C_im );
scatter( midpoints(1,:), midpoints(2,:), 16, '*r')

hold on

plot( midpoints(1,hullPoints), midpoints(2,hullPoints) );
plot( nonConvexMidpoints(1,hullPoints2), nonConvexMidpoints(2,hullPoints2), 'm' );

allpoints = [ midpoints(:,hullPoints) , midpoints(:,nonConvexMidpointIds( hullPoints2 )) ];

scatter( allpoints(1,:), allpoints(2,:), 20,'og','LineWidth',4);


