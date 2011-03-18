function [l_var, ds, ls] = plotDAgainstVarl( im_coords, n, known_d )

ds = 2:0.05:20;

ls = zeros(max(size(ds)), size(im_coords,2)/2);
l_var = zeros(max(size(ds)), 1);
l_var_norm = zeros(max(size(ds)), 1);
l_mu = zeros(max(size(ds)), 1);

% rectify using known d, find variance
plane = struct('n', n', 'd', known_d);
wc = find_real_world_points( im_coords, plane );

% Work out l for each pair of coords
[~,~,known_d_ls] = findLengthDist( wc, 0 );

num = 1;
h = waitbar(0,'Starting...', 'Name', sprintf('%d iterations', numel(ds)));

for d = ds,
    
    % Given a normal and a set of image coords, rectify with [d,n]
     plane = struct('n', n', 'd', d);
     wc = find_real_world_points( im_coords, plane );

    % Work out l for each pair of coords
    % FIND ERROR FROM 1..
    [l_mu(num),v_tmp,ls(num,:)] = findLengthDist( wc, 0 );
    l_var(num) = v_tmp;
    l_var_norm(num) = v_tmp / d;
    waitbar(num / numel(ds), h, sprintf('Running Iteration: %d (%d%%)',num, round((num / numel(ds)) * 100)));
    num = num + 1;
    
end
delete(h)

% plot var(l) against d
figure,
scatter( ds, l_var, 'og' );
hold on;
scatter( ds, l_var_norm, 'ok' );
scatter( known_d, std(known_d_ls),'*m' );
