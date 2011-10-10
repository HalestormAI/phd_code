NUM_BARS = 16;

STEP  = range(midpoints(2,:)) / NUM_BARS;
START = min(midpoints(2,:));
END   = max(midpoints(2,:));


bars = zeros(NUM_BARS,1);

for b=1:NUM_BARS;
    
    ids = intersect( find(midpoints(2,:) >= START+(b-1)*STEP), find(midpoints(2,:) < START+(b)*STEP) );
    lengths = L1(ids);
    bars(b) = mean(lengths);
    labels(b) = START+(b-1)*STEP;
    
end

figure,bar(labels,bars);