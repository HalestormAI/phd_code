button = questdlg('This will clear and close all...','Confirm','OK','Cancel','OK');

if ~strcmp(button,'OK'),
    return;
end
clear,clc,close all;
load singleplane;

TEST_D = plane.d;
ABC = plane.n ./ plane.d;
TEST_ALPHA = plane.alpha;

[T,P] = anglesFromN(plane.n);

increments  = 10.^(-2:0.05:1);
offsets_t   = deg2rad([-increments(end:-1:1),0,increments].*9);
offsets_p   = deg2rad([-increments(end:-1:1),0,increments].*4.5);
thetas      = T+offsets_t;
psis        = P+offsets_p;

for i=1:length(thetas),
    for j=1:length(psis),
        normals((i-1)*length(psis)+j,:) = normalFromAngle(thetas(i),psis(j),'radians');
        indices((i-1)*length(psis)+j,:) = [thetas(i),psis(j)];
    end
end

% Fix d and alpha to correct values
starts = [normals./TEST_D,repmat(TEST_ALPHA,length(normals),1)];

errors = cell2mat(cellfun(@(x) [sum(gp_iter_func(x,im_coords).^2)], num2cell(starts,2), 'UniformOutput',false));
[~,MINIDX] = min(errors);
figure;
scatter3(indices(:,1),indices(:,2),log10(errors));
hold on;
p1l1 = plot3( [T T],[P P],[min(log10(errors)) max(log10(errors))], 'm-' );
p1l2 = plot3( [T T],[-0.8 0.8],[min(log10(errors)) min(log10(errors))], 'm-' );
p1l3 = plot3( [-1.5 2],[P P],[min(log10(errors)) min(log10(errors))], 'm-' );

figure;
scatter3(starts(:,1),starts(:,2),starts(:,3),24,log10(errors))
hold on;
axes_max = max(starts,[],1);
axes_min = min(starts,[],1);
l1 = plot3( [ABC(1) ABC(1)],[ABC(2) ABC(2)],[axes_min(3) axes_max(3)], 'm-' );
l2 = plot3( [ABC(1) ABC(1)],[axes_min(2) axes_max(2)],[ABC(3) ABC(3)], 'm-' );
l3 = plot3( [axes_min(1) axes_max(1)],[ABC(2) ABC(2)],[ABC(3) ABC(3)], 'm-' );
l4 = plot3( [starts(MINIDX,1) starts(MINIDX,1)],[starts(MINIDX,2) starts(MINIDX,2)],[axes_min(3) axes_max(3)], 'b-' );
l5 = plot3( [starts(MINIDX,1) starts(MINIDX,1)],[axes_min(2) axes_max(2)],[starts(MINIDX,3) starts(MINIDX,3)], 'b-' );
l6 = plot3( [axes_min(1) axes_max(1)],[starts(MINIDX,2) starts(MINIDX,2)],[starts(MINIDX,3) starts(MINIDX,3)], 'b-' );

