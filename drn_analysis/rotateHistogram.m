function roth = rotateHistogram( h )
% Takes a direction histogram and rotates it S.T. the principle direction
% comes first
    [~,maxidx] = max(h);
    roth = [h(maxidx:end),h(1:maxidx-1)];
end