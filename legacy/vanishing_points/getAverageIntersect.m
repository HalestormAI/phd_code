function [Is,comparisons] = getAverageIntersect( C_all, C_n_all, idx, draw )

if nargin < 4,
    draw = 1;
end

C = C_all(:,:,idx);
C_n = C_n_all(:,:,idx);


Is = zeros( size(C) );
comparisons = zeros(2, size(C,2));
num = 1;
for i=1:size(C,2),
    for j=i+1:size(C,2),
        [dred,U1] = linefunc3d( C(:,i), C_n(:,i), 100 );
        [sdfd,U2] = linefunc3d( C(:,j), C_n(:,j), 100 );
        Is(:,num) = line_intersect3( U1,U2, C_n(:,i),C_n(:,j) );
        comparisons(:,num) = [i;j];
        num = num + 1;
    end
end

if draw,
    I = median(Is,2);
    compareEstResult(C_all,C_n_all,idx);
    hold on
    plot3( [I(1) I(1)], [ I(2) I(2)], [-250 50], 'k-' )
    plot3( [I(1) I(1)], [ -60 120], [I(3) I(3)], 'k-' )
    plot3( [-20 120], [ I(2) I(2)], [I(3) I(3)], 'k-' )
end