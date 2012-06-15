function drawAssignment( t1, t2, assignment )

    row = find(assignment ~= 0);
    col = assignment(row);
    xs = [t1(1,row);t2(1,col)];
    ys = [t1(2,row);t2(2,col)];
    drawtraj(t1,'',0)
    drawtraj(t2,'',0,'r');
    plot(xs,ys,'-b');

end