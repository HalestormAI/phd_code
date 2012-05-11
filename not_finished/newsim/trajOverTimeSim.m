NUM_FRAMES = 151;

f = drawPlane( worldPlane,'',1,'r' );
axis equal;
ax = axis;
fnum = 1;

for t=1:1:NUM_FRAMES

    for tj=1:length(traj)
        t0 = startframes(tj);
        
        if (t-1) >= t0 && (t) < t0 + length(traj{tj}),
            drawcoords3(traj{tj}(:, t-t0:t-t0+1),'',0,'k',0,'');
        end
    end
            
    axis(ax);
    if mod(t,2) == 1
        M(fnum) = getframe;
        fnum = fnum + 1;
    end
end
