% Create a series of connected planes, with time controlled tracklets on
% them.

% alpha controls scale
ALPHA = 1/720;
coords = [];

NUM_POINTS = 20;

% layout vertices for planes in 3d (metres, top right as 0)
planes(1).points = [      0   15.0000   15.0000         0
                         0         0   15.0000   15.0000
                   -4.5000   -4.5000   -9.0000   -9.0000];
[planes(1).n,planes(1).d]     = planeFromPoints(planes(1).points);
planes(1).impoints = round(wc2im(planes(1).points,-1/720));

planes(2).points = [        0   15.0000   15.0000         0
                     15.0000   15.0000   30.0000   30.0000
                     -9.0000   -9.0000   -10.5000   -10.5000];
[planes(2).n,planes(2).d]     = planeFromPoints(planes(2).points);
planes(2).impoints = round(wc2im(planes(2).points,-1/720));

%% Define Starting area [xmin,xmax;ymin,ymax;zmin;zmax] in plane 1
mins = min(planes(1).points,[],2);
maxs = max(planes(1).points,[],2);
STARTING_AREA = [ mins(1)+0.2*maxs(1) 0.8*maxs(1); 
                  mins(2)+0.2*maxs(2) 0.8*maxs(2);
                  mins(3) maxs(3)];

rottoz = makehgtform('xrotate',anglesFromN(planes(1).n));
%% init a set of points randomly in starting area. Assign directions &
% velocities 
start      = cell(NUM_POINTS,1);
directions = cell(NUM_POINTS,1);
velocities = cell(NUM_POINTS,1);
for i=1:NUM_POINTS,
    % Random x
    x = randi(STARTING_AREA(1,2)-STARTING_AREA(1,1)) + STARTING_AREA(1,1);
    % Random y
    y = randi(STARTING_AREA(2,2)-STARTING_AREA(2,1)) + STARTING_AREA(2,1);
    z = (planes(1).d - planes(1).n(1)*x - planes(1).n(2)*y)/planes(1).n(3);
    
    start{i} = [x;y;z];
    % rotate onto z plane, rotate in z, rotate back
    randangle = rand(1)*pi/10;
    rad2deg(randangle)
    randomrot = makehgtform('zrotate',randangle);
    pln_drn = (planes(1).points(:,4)- planes(1).points(:,1));
    rand_drn = rottoz'*randomrot*rottoz*makeHomogenous(pln_drn);
%     acosd(dot(rand_drn(1:3), pln_drn) /
%     (norm(rand_drn(1:3))*norm(pln_drn)))
    pln_drn = rand_drn(1:3);
    
    directions{i} = pln_drn./norm(pln_drn);
    velocities{i} = 1;
end

startmat = cell2mat( start' )

%% Draw planes with points on them
colours = ['b','r','g','m'];
if(exist('manual','var'))
    f = drawSimPlanes( planes, [], colours );
    scatter3(startmat(1,:),startmat(2,:),startmat(3,:), 'k*');
end


%% Now move points
previous = start;
for frame=1:19,
    [current,directions] = movePoints(previous, directions, velocities, planes);
    currentmat = [current{:}];
    previousmat = [previous{:}];
    coords = [coords,[interleave(previousmat(1,:),currentmat(1,:));...
                      interleave(previousmat(2,:),currentmat(2,:));...
                      interleave(previousmat(3,:),currentmat(3,:))]
             ];
    for i=1:length(current),
        plot3([previousmat(1,i),currentmat(1,i)],...
              [previousmat(2,i),currentmat(2,i)],...
              [previousmat(3,i),currentmat(3,i)],'m-')
    end
    
    if(exist('manual','var'))
        pause
        figure(f);
    end
    previous = current;
end