function [newMean, ok_planes,f] = removeOutliersFromMean( planes, n, draw )

STD_COEFF = 2;

if nargin < 3,
    draw = 1;
end

% Find the mean
mu_p = mean(planes,1);

% Get the covar mat (x,y,z)
cov_p = cov( planes );

% Diagonals give variance on each column
std_p = sqrt( diag( cov_p ) )';

%% find all points outside of 3 sd's
% Distance of all points from the mean
dists = abs( planes - repmat(mu_p,size(planes,1),1) );
bigger = dists > repmat( std_p.*STD_COEFF, size(planes,1), 1 );

good_idx = find( ~sum(bigger,2) );
bad_idx  = find( sum(bigger,2) );

ok_planes  = planes( good_idx, : );

newMean = mean( ok_planes, 1 );

if draw,
    %% Draw axes and planes
    
    % Get full "n" by creating array of structs
    drawPlanes = cellfun( @iter2plane, num2cell(planes,2), 'UniformOutput', 1 );
    structGood   = drawPlanes( good_idx, : );
    structBad    = drawPlanes(  bad_idx, : );
    drawGood     = [structGood.n];
    drawBad      = [structBad.n ];
    f = figure('Position',[0 -50 1280 1024]);
    hold on,
    if ~isempty(drawBad),
        scatter3(  drawBad(1,:), drawBad(2,:), drawBad(3,:),'ro' );
    end
    if ~isempty(drawGood),
        scatter3( drawGood(1,:),drawGood(2,:),drawGood(3,:),'g*' );
    end
    muPlane = iter2plane(mu_p);
    scatter3( muPlane.n(1), muPlane.n(2), muPlane.n(3),'bo' );
    
    newMeanPlane = iter2plane( newMean );
    scatter3( newMeanPlane.n(1), newMeanPlane.n(2), newMeanPlane.n(3,:),'b*' );
    scatter3( n(1), n(2), n(3), 'm*');
    % [x,y,z] = ellipsoid( mu_p(2),mu_p(3),mu_p(4), std_p(2), std_p(3), std_p(4) );
    % mesh(x,y,z, 'FaceAlpha',0, 'EdgeAlpha', 0.5, 'EdgeColor',[0.5,0.5,0.5]);
    % [x2,y2,z2] = ellipsoid( mu_p(2),mu_p(3),mu_p(4), 2*std_p(2), 2*std_p(3),
    % 2*std_p(4) );
    % mesh(x2,y2,z2, 'FaceAlpha',0, 'EdgeAlpha', 0.5, 'EdgeColor',[0,0,0.5]);
    % [x3,y3,z3] = ellipsoid( mu_p(2),mu_p(3),mu_p(4), 3*std_p(2), 3*std_p(3), 3*std_p(4) );
    % mesh(x3,y3,z3, 'FaceAlpha',0, 'EdgeAlpha', 0.5, 'EdgeColor',[0.5,0,0]);
    title('Plane estimation points with mean, actual and covariance');
    xlabel('n_x');
    ylabel('n_y');
    zlabel('n_z');
    l = legend( 'Planes outside $2\Sigma$', ...
                'Planes within $2\Sigma$', ...
                'Initial $\mu(\textbf{n})$', ...
                '$\mu(\textbf{n})$ after removing outliers', ...
                'Known $\textbf{n}$' );
    axis([-1 1 -1 1 -1 0]);
    grid on;
    set(l,'Interpreter','latex')

end