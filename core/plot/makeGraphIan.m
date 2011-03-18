function makeGraph

close all


% number ranges for each of the things
wt = [1906.2 1925.2 1731.7 2310 2303.2  3506.2 2953.1  2634.7 3664.4 ...
    4003.2 4677.3 5209.6]

oe = [2156.4  2341.6 2032.6 2417.8 1798 2265.8 1575.5 2378 2295.3 1427.4 ...
2437.2 1817]

kd = [1400.1 1325.6 1575.6 1475.8 1845.1 1935 2147.4 1309.7 1983.3 ...
1720.5 2565.3 2596.9]

%wt = [29.4989   24.7737   13.7411   18.7062   31.9859   32.6724 ...
 %   30.5820   16.4169 33.2992   23.0995   24.1490   17.8993]

%oe = [14.0031   16.8315   23.4448   14.1958   17.1978   24.4875...
 %   18.3986   20.2435 15.1989   26.0761   24.1652   28.3119]

%kd = [25.9187   10.7895   17.0579   20.7088   24.3383   17.2023 ...
 %   25.5793   19.2870  28.8938   12.5603   12.9492   25.4094]

xVal = [1:12]



wt = sort(wt)
oe = sort(oe)
kd = sort(kd)

plot (xVal,wt)
hold on
plot(xVal,oe, 'color', 'red')
hold on
plot(xVal,kd, 'color', 'green')

std(wt)

wtM = mean(wt)
oeM = mean(oe)
kdM = mean(kd)

wtS = std(wt)
oeS = std(oe)
kdS = std(kd)

save wt
save oe
save kd


% manually set the x and y range of the axis
figure
axis([0 7 1200 6000])
[rec1] = rectangle('position',[1 wtM-wtS 1 ((wtM+wtS)-(wtM-wtS))], 'FaceColor','r')

[rec2] = rectangle('position',[3 oeM-oeS 1 ((oeM+oeS)-(oeM-oeS))], 'FaceColor','r')

[rec3] = rectangle('position',[5 kdM-kdS 1 ((kdM+kdS)-(kdM-kdS))], 'FaceColor','r')
hold on
plot([1.5 3.5 5.5], [wtM oeM kdM], 'ko', 'MarkerFaceColor', 'k')
hold on

% manually plot the 'lines' (min and max)
plot([1.5 1.5],[1732 5210], 'k-')
plot([3.5 3.5],[1427 2437], 'k-')
plot([5.5 5.5],[1310 2597], 'k-')
hold on
% I never got around to putting the little bars on that they should have 
% so they look more like | than I (if you can be bothered writing that
% bit then please send me it  :-) )

%plot([0 10], [2323 2323], 'k--')