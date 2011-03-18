function [norms_f,mean_f,M] = clever_mean( planes, n )

    norms     = planes(:,2:4);
    idx       = 1:size(norms,1);
    M         = moviein(size(norms,1));
    
    iterNorms = cell ( numel(idx), 1 );
    means     = cell ( numel(idx), 1 );
%    iterMeans = cell ( numel(idx), 1 );
    pt_ratio  = zeros(1, size(norms,1) );
    point_sd  = cell ( numel(idx), 1 );
    %means     = cell( numel(idx)-1, 1 );

    fnum = 1;
    fld = getTodaysFolder( );
    a = dir(strcat('./',fld,'/run*'));
    next_id = size(a([a.isdir] == 1),1) + 1;
    mkdir( sprintf('./%s/run%d', fld, next_id ) );
    while numel(idx) > 1,
        % Find mean of all points
        mn_norm = mean(norms,1);
        means{numel(idx)} = mn_norm(1:3);
        iterMeans{fnum} = mn_norm;
        mn_std = std(norms,1,1)
        point_sd{fnum} = mn_std;
        iterNorms{numel(idx)} = norms;
        
        % Find distance of all points from mean
        dists = cellfun(@(x) vector_dist(x, mn_norm), num2cell( norms,2 ) );

        % Remove furthest point
        [~,idx] = sort( dists, 'ascend' );
        norms = norms(idx(1:end-1),:);

        % Number of points within 1 std dev / number of points not
%         pt_ratio(numel(idx)) = max(size(find( dists <= 0.5*mn_std ) )) ...
%                    / max(size(find( dists >  0.5*mn_std ) ));

        %% Plot and save movie frame
         f=figure('Position',[0 -50 1024 512]);
         subplot(1,2,1);
         hold on   
         scatter3( norms(:,1), norms(:,2), norms(:,3), 'g' );
         scatter3(mn_norm(1),mn_norm(2),mn_norm(3),'b*')
         if nargin == 2,
             scatter3(n(1),n(2),n(3),'m*');
         end
         xlabel('x'),ylabel('y'),zlabel('z');
         axis([ -1 1 -1 1 -1 1 ] );
         grid on;
         view(37,34);
         hold off
         % Distance from N
         subplot(1,2,2);
         distFromN = cellfun(@(x) vector_dist(x, n'), iterMeans );
         scatter( 1:numel(distFromN), distFromN );
         axis( [ 0 200 0 0.8 ] );
         title( 'Distance from N' );
         
         M(:,fnum) = getframe(f);
        if numel(idx) == 2,
            saveas(f,sprintf('./%s/run%d.fig',fld,next_id),'fig' );
        end
        close(f);
%% plot end
        fnum = fnum + 1;
    end % repeat ad infinitum
    movie2jpgs( M, sprintf('run%d', next_id ) );

    [m,i] = min( abs(mean(round(dydx*1000),2)) )
    norms_f = iterNorms{i};
    mean_f  = iterMeans{i};
 
    
end
