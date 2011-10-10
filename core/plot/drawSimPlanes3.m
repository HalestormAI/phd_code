function f = drawSimPlanes3( planes, coords, camera )
f = figure;
hold on;
grid on;
colours = ['b','r','g','m'];
max_ax = [0;0;0];
min_ax = [999;999;999];
for p=1:length(planes),
    max_ax = max(max_ax,max(planes(p).points,[],2));
    min_ax = min(min_ax,min(planes(p).points,[],2));
    for i=1:4,
        j=mod(i,4)+1;
        plot3( planes(p).points(1,[i,j]),planes(p).points(2,[i,j]),planes(p).points(3,[i,j]), colours(p) );
    end
end
axis(interleave(min_ax,max_ax));
view(74,12);
xlabel('x');ylabel('y');zlabel('z');
if nargin > 1,
    drawcoords3(coords,'',0,'k');
end
if nargin > 2 && camera,
    scatter3(0,0,0,45,'og')
    scatter3(0,0,0,45,'*g')
end