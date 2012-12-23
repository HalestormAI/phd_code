endframes = startframes'+cellfun(@length, camTraj);
drawn = zeros(length(camTraj),1);
MAX_FRAME = max(endframes);
TIMESTEP = 1;

f = drawPlane( camPlane,'',1,'k' );
axis equal;
ax = axis;
fnum = 1;

if ~exist('frames','dir')
    mkdir('frames');
end

for t=1:TIMESTEP:MAX_FRAME

    for tj=1:length(camTraj)
        
        if t > endframes(tj) && ~drawn(tj)
            drawtraj(camTraj{tj},'',0,'k');
            drawn(tj) = 1;
        end
        
        t0 = startframes(tj);
        
        if (t-1) >= t0 && (t) < (t0 + size(camTraj{tj},2)),
            drawtraj(camTraj{tj}(:, t-t0:t-t0+1),'',0,'r',0,'');
        end
    end
            
    axis(ax);
    %if mod(t,2) == 1
        saveas( f, sprintf('frames/frame_%04d.fig',fnum));
%         M(fnum) = getframe;
        fnum = fnum + 1;
    %end
end
