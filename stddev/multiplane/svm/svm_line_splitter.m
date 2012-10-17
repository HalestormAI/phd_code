
% Train an SVM on assignments to get approximate plane divider line
figure;
svm = svmtrain(centres(full_regions,:), MINIDS(full_regions),'showPlot','true');
hold on;

% Get the line data from the plot
ax = svm.FigureHandles{1};
kiddies = get(ax,'Children');
hghand = kiddies(1);
linehandle = get(hghand,'Children');
xvals = get(linehandle,'XData');
yvals = get(linehandle,'YData');

% Use line data to get equation
m=(yvals(2)-yvals(1))/(xvals(2)-xvals(1));
b=yvals(1)-m*xvals(1);
% plot(xvals, m*xvals+b, '--', 'LineWidth', 3);
close;

linePoints = [xvals(~isnan(xvals)), yvals(~isnan(yvals))]; % Line points is transpose of coord system.

% Get angle of line
angles1 = atan2( diff(linePoints([1,end],2)), diff(linePoints([1,end],1)) );

% Get vertical angle
angles2 = atan2( 700, 0);

% Get difference
angle = rad2deg(angles1-angles2)-90;

% Centre of line
centre = mean(linePoints([1,end],:))';

[sideTrajectories,sideTrajectoryId] = multiplane_split_trajectories_for_line( imTraj, centre, angle, 0, 'm' );




history(iteration).output_mat   = output_mat;
history(iteration).fullErrors   = fullErrors;
history(iteration).centre       = centre;
history(iteration).angle        = angle;
history(iteration).regions      = regions;



region_intersect = minmax(linePoints');

% figure;
% hold on;

clear regions;
for r=1:2
    regions(r).traj = sideTrajectories{r};
    regions(r).centre = mean(minmax([sideTrajectories{r}{:}]),2);
    regions(r).radius = max(range([sideTrajectories{1}{:}],2));
end
