% [N,vecs,vec_im] = makeNoisyVectors( 30, -15, 8, -0.03, [0.1 0.2 0.05], 1000 );
gt_lengths = vector_dist( vecs );
gt_lengths_norm = gt_lengths / mean(gt_lengths);
grid = generateNormalSet( );
dist_comparison = cellfun( @(x) compareLengthDistributions( x, gt_lengths_norm, vec_im ), num2cell(grid,2) );
GOODGRID = grid(dist_comparison,:);


ERRORS = cellfun( @(x) sum(gp_iter_func(x,vec_im).^2), num2cell(GOODGRID,2));

[~,minidx] = min(ERRORS)
1/norm(GOODGRID(minidx,1:3))
abc2n(GOODGRID(minidx,1:3))

RECT = find_real_world_points(vec_im, iter2plane(GOODGRID(minidx,:)));
mu_lrectnorm = findLengthDist( RECT );
RECT_NORM = RECT./mu_lrectnorm;

findLengthDist( RECT_NORM );
title('Estimated Simulated Vector Lengths');
findLengthDist( vecs );
title('Ground-Truth Simulated Vector Lengths');