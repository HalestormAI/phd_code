
input_cost =  cell(length(imtraj),length(imtraj));
assignment =  cell(length(imtraj),length(imtraj));
outputcost = zeros(length(imtraj),length(imtraj));


for i=1:length(imtraj)
    for j=i:length(imtraj)
        input_cost{i,j} = cluster_traj( imtraj{i},imtraj{j} );
        fprintf('Done building error matrix (%d,%d)',i,j);
        [assignment{i,j},outputcost(i,j)] = assignmentoptimal( input_cost{i,j} );
        fprintf('Element (%d,%d) of (%d,%d)\n',i,j,length(imtraj),length(imtraj));
%         row = find(assignment ~= 0);
%         col = assignment(row);
%         xs = [imtraj{1}(1,row);imtraj{2}(1,col)];
%         ys = [imtraj{1}(2,row);imtraj{2}(2,col)];
%         drawtraj(imtraj{1});
%         drawtraj(imtraj{2},'',0,'r');
%         plot(xs,ys,'-b');
    end
end