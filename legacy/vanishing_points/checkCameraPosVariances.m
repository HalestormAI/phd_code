function checkCameraPosVariances(c,c_n,a)
vars = zeros(1, size(c,3) );
%h = waitbar(0,'Starting...', 'Name', sprintf('Running Tests'));

parfor j=1:size(c,3),
 %waitbar(j / size(c,3), h, sprintf('Running Iteration: %d (%d%%)',j, round((j / size(c,3)) * 100)));
 Is = getAverageIntersect(c,c_n,j,0);
 vars(j) = median(var(Is));
end

scatter( 0:0.0002:0.2, vars, 10, a, '*')
xlabel('Noise Level');
ylabel('Variance in camera intercept location');
c = colorbar;
ylabel(c, 'Angle size')
%delete(h)