function [cluster_info,planes,n,used_vectors,imc,wc] ...
    = videoPointEstimation( imc, n, num_iters, num_vecs, exp_id,exp_name )
% Runs the plane detection algorithm a number of times on video data,
% plots them and their mean, then plots a comparison graph of the known and
% estimated plane.
%
% INPUT:
%   im_coords    Set of image coords taken from video
%   n            Known normal from homography matrix
%   num_iters    Number of experiments to run
%   num_vecs     Number of vectors to use in solver (N.B. > 4 is SLOW)
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

if nargin == 4,
    mkdir('.',sprintf('%s',datestr(now, 'dd-mm-yy')));
end


%% Run algo n times
planes = zeros( num_iters, 4 );
used_vectors = zeros( num_iters, num_vecs * 2 );
h = waitbar(0,'Starting...', 'Name', ...
            sprintf('Running %d iterations', num_iters ));
fails = 0;
for i=1:num_iters,
    fprintf( 'Iteration: %d\n', i );
    done = 0;
    while ~done,
        try
            [ ~, p, used_vectors(i,:),attempts ] = iterate_to_gp( imc, 0, num_vecs );
            fails = fails + attempts;
            % Check that plane is valid
%             disp('attempt')
            [validn, validd] = checkPlaneValidity( p );
            if validn,
                planes(i,:) = p;
                
                % rectify image coords
                rw = find_real_world_points(imc, iter2plane( p ));
                
                % what's the mu and sd?
                [mul,sdl,ls] = findLengthDist( rw, 0 );
                
                % if more than e.g. 10 > mu+/-sd, BAD
                numbads = length(find( abs(ls - mul) > sdl ));
                
                if numbads > 0.1*size(imc,2),
                    disp('Invalid distro found');
                else
                    done = 1;
                end
            elseif ~validn,
                fprintf( 'Invalid n detected: %g\n', p(2:4) );
            else
                fprintf( 'Invalid d detected: %d\n',p(1) );
            end
        catch e,
            disp(e.message);
            fails= fails+10;
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
if nargin >5,
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

    fname_output = sprintf('%s/experiment_%d_ns.fig',datestr(now, 'dd-mm-yy'),exp_id);
    saveas(f,fname_output,'fig');
    
    % now need to append log file
    myfile = fopen(sprintf('%s/experiments.txt',datestr(now, 'dd-mm-yy')),'a');
    fprintf(myfile, '%d) %s, iters=%d,num_vecs=%d. \n', ...
        exp_id, exp_name,num_iters, num_vecs);
end
mean_plane = mean(planes,1);
wc = find_real_world_points( imc, iter2plane(mean_plane) );
