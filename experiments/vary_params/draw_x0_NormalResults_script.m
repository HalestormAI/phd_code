figure;
hold on
% for i = 1:5,
%     groups(i) = hggroup;
%     set(get(get(groups(i),'Annotation'),'LegendInformation'),...
%         'IconDisplayStyle','on'); 
% end
%  
 
colours   = ['g','r','m','b','c', 'k'];
% edgecol   = ['g','r','w','w','c', 'w'];
markers   = ['*','+','o','s','v', 'd'];
labels = {'Correct', 'Non-convergence','Implausible Normal','Implausible D', 'Implausible Distribution', 'Non-Fitting Distribution'};
Ns = zeros(3,size(angarr,1));
for i=1:size(angarr,1),
    Ns(:,i) = normalFromAngle( angarr(i,1), angarr(i,2), 'degrees' );
end

lgnd = cell(0);

for i = 1:6,
    
    Nids = find(failReason == i-1);
    if ~isempty(Nids),
        theseNs = Ns(:,Nids);

        colour = colours(i);
        marker = markers(i);

        scatter3( theseNs(1,:), theseNs(2,:), theseNs(3,:), sprintf('%s%s',marker, colour));
        lgnd{end+1} = labels{i};
    end
end
lgnd{end+1} = 'Actual Normal'


xlabel('nx')
ylabel('ny')
zlabel('nz')
axis([ -1 1 -1 1 -1 0]);

truthGroup = hggroup;

p1 = plot3( [ actual_n(1) actual_n(1) ],[ actual_n(2) actual_n(2) ],[ -1 0 ], 'm' );
p2 = plot3( [ actual_n(1) actual_n(1) ],[ -1 1 ],[ actual_n(3) actual_n(3) ], 'm' );
p3 = plot3( [ -1 1 ],[ actual_n(2) actual_n(2) ],[ actual_n(3) actual_n(3) ], 'm' );
set(p1, 'Parent', truthGroup );
set(p2, 'Parent', truthGroup );
set(p3, 'Parent', truthGroup );

set(get(get(truthGroup,'Annotation'),'LegendInformation'),...
     'IconDisplayStyle','on'); 
 
legend(lgnd);
grid on;