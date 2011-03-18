function [planes, clusters, cluster_size, quality, ids, x0]  = combineIters( im_coords, num_iters, rands, N )

if nargin < 3,
    rands = 3;
end

planes = zeros(num_iters,4);
ids = zeros(num_iters,rands*2);
fails = zeros(num_iters,1);
h = waitbar(0,'Starting...', 'Name', sprintf('%d iterations', num_iters));
for i=1:num_iters,
    
    waitbar(i / num_iters, h, sprintf('Running Iteration: %d (%d%%)',i, round((i/num_iters) * 100)));

    % Keep running on different combos of points until we converge
    done = 0;
    attempts = 0;
    while attempts < 20 && ~done,
        % Generate a random intial starting point
        x0 = generateNormal( );
        attempts_inner = 0;
        while attempts_inner < 20 && ~done,
           % ids_full = monteCarloPaths( im_coords, rands,3,15 );
            [ ~, x_iter, ids(i,:), debug_info, x0 ] = iterate_to_gp_video( im_coords, x0, rands, 'MONTECARLO', 0 );
            
            [validn,validd] = checkPlaneValidity( x_iter );
            fprintf('Have a plane, N: %d, D: %d\n',validn,validd);
            done = debug_info.exitFlag > 0 && validn;
            attempts = attempts + 1;
            attempts_inner = attempts_inner + 1;
            if ~done,
                fprintf('Fail on iteration: %d\n', i);
            end
        end
        if ~done,
            disp('Fail after 20 iters');
        end
    end
    if attempts >= 50,
        fails(i) = 1;
    end
    fprintf('iter %d complete\n',i)
    planes(i,:) = x_iter;
    
end
delete(h)

% Now we have a set of converged planes, begin by clustering. We should
% have 1 cluster only.

[clusters, cluster_size, quality] = gmeans(planes);
figure,
scatter3( clusters(:,2), clusters(:,3), clusters(:,4) )
hold on,
scatter3( planes(:,2),planes(:,3),planes(:,4), '*g' )
axis([-1,1,-1,1,-1,0]);
if nargin == 4,
    scatter3( N.b(1), N.b(2), N.b(3), 'or' )
    scatter3( N.a(1), N.a(2), N.a(3), 'or' )
end
    
xlabel('x'),ylabel('y')