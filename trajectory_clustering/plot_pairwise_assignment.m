function [ass] = plot_pairwise_assignment( i, j, imtraj, assignment, frame, distance )

    figure;
    image(frame);
    
    drawtraj(imtraj{i},'',0,'k',3,'-o');
    drawtraj(imtraj{j},'',0,'r',3,'-o');
    
    ass = assignment{i,j};
    
    
    for a=1:length(ass)
        if a > 0 && ass(a) > 0
            x = [imtraj{i}(1,a),imtraj{j}(1,ass(a))];
            y = [imtraj{i}(2,a),imtraj{j}(2,ass(a))];
            plot(x,y,'b-','LineWidth',3);
        end
    end
end