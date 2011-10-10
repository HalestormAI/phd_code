function f = drawSimPlanes( planes, coords, colours, mode, camera )
f = figure;
hold on;
grid on;

if nargin < 4 || isempty(mode),
    mode = 'wc'
end

if strcmp(mode,'wc')
    max_ax = [0;0;0];
    min_ax = [999;999;999];
else
    max_ax = [0;0];
    min_ax = [999;999];
end
for p=1:length(planes),
    if strcmp(mode,'wc'),
        max_ax = max(max_ax,max(planes(p).points,[],2));
        min_ax = min(min_ax,min(planes(p).points,[],2));
        for i=1:4,
            j=mod(i,4)+1;
            plot3( planes(p).points(1,[i,j]),planes(p).points(2,[i,j]),planes(p).points(3,[i,j]), colours(p) );
        end
        view(74,12);
        zlabel('z');
        axis(interleave(min_ax,max_ax));
    else
        max_ax = max(max_ax,max(planes(p).impoints(1:2,:),[],2));
        min_ax = min(min_ax,min(planes(p).impoints(1:2,:),[],2));
        for i=1:4,
            j=mod(i,4)+1;
            plot( planes(p).impoints(1,[i,j]),planes(p).impoints(2,[i,j]), colours(p) );
        end
        axis(interleave(min_ax,max_ax));
    end
end
xlabel('x');ylabel('y');
if nargin > 1 && ~isempty(coords),
    drawcoords3(coords,'',0,'k');
end
if nargin > 4 && camera,
    scatter3(0,0,0,45,'og')
    scatter3(0,0,0,45,'*g')
end