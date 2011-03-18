function [std_devs,means,mins,maxs] = makeGraph( pieces, save_data )
% Draw candlestick graphs
%
% Input:
%    pieces:    Matrix containing row vectors of data to be plotted.

% Plot values
figure,
plot (1:size(pieces,2),sort(pieces,2))

% Get standard deviation and mean of each row
std_devs = std(pieces,0,2);
means    = mean(pieces,2);
mins     = min(pieces,[],2);
maxs     = max(pieces,[],2);

% If we want to save the data
if nargin >= 2 && save_data,
   save( strcat('graph_data_','date','.mat'), 'pieces', 'std_devs', ...
         'means', 'mins', 'maxs' );
end


% Set positions for each plot
gap = 1;
col_idx = [1:gap:size(pieces,1)*gap]' - gap / 4;

% Set intervals (used for box/line widths)
sml_tick = gap / 8;
mid_tick = sml_tick * 2;
lrg_tick = sml_tick * 3;

% Set rectangle height/width
heights = (means+std_devs) - (means-std_devs);
widths  = ones(size(pieces,1),1).*gap/2;

% Set rectangle position vector
positions = [ col_idx, means-std_devs, widths, heights];

% Make axis max and min (vertical is .5 SD either side of range)
figure,
set(gca,'XTick',col_idx+ gap/4);
hold on
minheight = min(min( pieces ))-max(std_devs)*.5;
maxheight = max(max( pieces ))+max(std_devs)*.5;
axis([gap-gap/2 size(pieces,1)*gap+gap/2 minheight, maxheight])

for i=1:size(positions,1),
    % Plot std deviation
    rectangle('position',positions(i,:), 'FaceColor','r');
    % Plot the range
    plot([ col_idx(i)+mid_tick,col_idx(i)+mid_tick ],[min(pieces(i,:)), max(pieces(i,:))], 'k-');
    % Min horizontal lines
    plot([ col_idx(i)+sml_tick,col_idx(i)+lrg_tick ],[min(pieces(i,:)), min(pieces(i,:))], 'k-');
    % Max horizontal lines
    plot([ col_idx(i)+sml_tick,col_idx(i)+lrg_tick ],[max(pieces(i,:)), max(pieces(i,:))], 'k-');
end
% Show mean dots.
plot(col_idx+mid_tick, means, 'ko', 'MarkerFaceColor', 'k')

% Title
title('Graph showing distribution of data groups in terms of standard deviation, mean and range');
