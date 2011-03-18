function spreadPointsTimings( )

range = [ 10, 50, 100, 200, 300, 500, 1000, 5000 ];
times = zeros( 1,max(size( range )) );

for i=1:max(size(range)),
    tic,
    spreadPoints( range(i), 3 );
    times(i) = toc,
end
range
times
save('function_timings.mat','range','times');
figure, semilogx( range, times );
title('Timings over increasing n');
xlabel('n')
ylabel('Timing (ms)')