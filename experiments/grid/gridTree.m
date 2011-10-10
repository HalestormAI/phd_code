function bestchance = gridTree( im_coords, grid, griderrors )

MAX_LEVEL = 2;
PROPORTION = 5e-4;

if nargin < 2,
    grid = generateNormalSet( );
end
if nargin < 3,
    griderrors  = cell2mat(cellfun(@(x) mean(gp_iter_func(x,im_coords).^2), num2cell(grid,2), 'UniformOutput',false));
end
[~,sortedids] = sort(griderrors);
best_few = sortedids(1:ceil(length(griderrors)*PROPORTION));
est = zeros(1,4);

fprintf('%d Level 1 Nodes to traverse\n\n', length(best_few));

parfor g = 1:length(best_few),
    % Enter grid, find errors
    fprintf('Entering Level %d, Node %d\n', 1, g );
    [est(g,:), est_error(g)] = gridTree_enterNode( grid(best_few(g),:), 1, MAX_LEVEL, PROPORTION, im_coords );
end

est

[~, minidx] = min(est_error);
bestchance = est(minidx,:);

end