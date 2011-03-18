function [cluster_info,planes,n,used_vectors,imc,wc] ...
    = simulatedPointEstimation( theta, psi, d, num_iters, num_vecs, NOISE_LEVEL, exp_id )
% Runs the plane detection algorithm a number of times on simulated data,
% plots them and their mean, then plots a comparison graph of the known and
% estimated plane.
% Each of the 3 types of noise can be given.
%
% INPUT:
%   theta        AoE for plane
%   psi          Yaw angle for plane
%   d            Distance of camera from plane
%   num_iters    Number of experiments to run
%   num_vecs     Number of vectors to use in solver (N.B. > 4 is SLOW)
%  *NOISE_LEVEL  Can be either a double between 0-1 (type 3) or a 3-vector
%  *exp_id       The experiment ID (used for recording experiments)
%
% OUTPUT:
%   cluster_info Cluster information: [Centres,Size,Quality] as per gmeans
%                (Currently only represents mean plane).
%   planes       The set of 4-d plane estimations ( [d_i,nx_i,ny_i,nz_i] ).
%   n            The actual, known n.
%   used_vectors A matrix of vector ids for each experiment.
%   imc          Simulated image coordinates.
%   wc           World coordinates generated using mean plane.

if nargin < 6,
    NOISE_LEVEL = zeros(1,3);
else
    if numel(NOISE_LEVEL) == 1,
        tmp = NOISE_LEVEL;
        NOISE_LEVEL    = zeros(1,3);
        NOISE_LEVEL(3) = tmp;
    elseif numel(NOISE_LEVEL) ~= 3,
        error('Invalid Noise Profile Given');
    end
end

if nargin == 7,
    mkdir('.',sprintf('%s',datestr(now, 'dd-mm-yy')));
end


%% Make n and image/rw coords - if we have type 2 noise, need to add here.
if NOISE_LEVEL(2) > 0,
    [ n, ~, ~, wc, imc_clean ] = make_test_data( theta, d, 1, psi, 100, NOISE_LEVEL(2) );
else
    [ n, wc, imc_clean ] = make_test_data( theta, d, 1, psi, 100 );
end

drawcoords3(wc,'',1,'k');
%% if we have type 1 noise, need to offset vectors from plane
if NOISE_LEVEL(1) > 0,
    [imc_clean, wc] = addType1Noise( wc, n, NOISE_LEVEL(1) );
end
drawcoords3(wc,'',0,'r');

im_ls = zeros(size(imc_clean,2)/2,1);
for i=1:2:size(imc_clean,2),
    im_ls(round((i+1)/2)) = vector_dist(imc_clean(:,i), imc_clean(:,i+1));
end
%im_sz = abs(max(max(C_im)))

im_sz = mean(im_ls)

%% add image noise
[ imc, ~ ] = add_coord_noise(imc_clean, NOISE_LEVEL(3), im_sz, 1);


%% Run algo n times
planes = zeros( num_iters, 4 );
used_vectors = zeros( num_iters, num_vecs * 2 );
h = waitbar(0,'Starting...', 'Name', ...
            sprintf('Running %d iterations', num_iters ));
for i=1:num_iters,
    fprintf( 'Iteration: %d\n', i );
    done = 0;
    while ~done,
        try
            [ ~, p, used_vectors(i,:) ] = iterate_to_gp( imc, 0, num_vecs );
            % Check that plane is valid
            [validn, validd] = checkPlaneValidity( p );
            if validn && validd,
                planes(i,:) = p;
                done = 1;
            elseif ~validn,
                fprintf( 'Invalid n detected: %g\n', p(2:4) );
            else
                fprintf( 'Invalid d detected: %d\n',p(1) );
            end
        catch %#ok<CTCH>
            continue;
        end
    end
    waitbar(i / num_iters, h, sprintf('Running Iteration: %d (%d%%)', ...
            i, round(i* 100 / num_iters) ));
        
end

delete( h )

%% If number of iterations is 1, we need only select that plane, else
%% cluster
if num_iters == 1,
    clusters = planes;
    cluster_size = 1;
    quality = 1;
else
    % Cluster
    %[clusters, cluster_size, quality] = gmeans( planes );
    % Find mean of planes
    clusters = mean(planes,1);
    cluster_size = 1;
    quality = 1;
end

%% display results
cluster_info = struct('clusters',clusters,'sizes',cluster_size,'quality',quality);
if nargin == 7,
    f = figure;
    scatter3( clusters(:,2), clusters(:,3), clusters(:,4) );
    hold on
    scatter3( planes(:,2), planes(:,3), planes(:,4), 'g' );
    scatter3( n(1), n(2), n(3), 'm*' );
    axis([ -1 1 -1 1 -1 0 ] );
    xlabel('x'),ylabel('y'),zlabel('z');
    mean_plane = mean(planes,1);
    scatter3(mean_plane(2),mean_plane(3),mean_plane(4),'k*')
    %% For each plane: Compare rectified points
    if size(clusters,1) < 5,
        for i=1:size(clusters,1),
            if nargin == 7,
                compareRectifiedandGT( n, clusters(i,2:4)', clusters(i,1), 20, imc, exp_id );
            else
                compareRectifiedandGT( n, clusters(i,2:4)', clusters(i,1), 20, imc );
            end
        end
    else
        disp('Too many clusters returned to display all');
    end
    
    %% put image coords in saved data

    fname_output = sprintf('%s/experiment_%d_ns.fig',datestr(now, 'dd-mm-yy'),exp_id);
    saveas(f,fname_output,'fig');
    
    % now need to append log file
    myfile = fopen(sprintf('%s/experiments.txt',datestr(now, 'dd-mm-yy')),'a');
    fprintf(myfile, '%d) [theta=%d,psi=%d,d=%d,iters=%d,num_vecs=%d. Noise: Type 1 - %.3f, Type 2 - %.3f, Type 3 - %.3f\n', ...
        exp_id, theta,psi,d,num_iters, num_vecs,NOISE_LEVEL(1),NOISE_LEVEL(2),NOISE_LEVEL(3));
end

