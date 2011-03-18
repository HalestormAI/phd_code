function [idx_pick,centroids_a,centroids_e,translations] = compareRectifiedandGT( N_a, N_e, d, num_vecs, vectors_full, in3d )

if nargin < 6,
    in3d = 0;
end

% Find d's to approximate equal scale;
d_a = findDFromNandImage( N_a, vectors_full );

% [t_a,p_a] = anglesFromN( N_a );
% t_a = rad2deg(t_a)
% p_a = rad2deg(p_a)
% [t_e,p_e] = anglesFromN( N_e );
% t_e = rad2deg(t_e)
% p_e = rad2deg(p_e)


% 
% t_diff = abs(t_a - t_e)
% p_diff = abs(p_a - p_e)

% Need to pick, for example 30 vectors
idx_full = randperm(size(vectors_full,2)/2);
idx_base = idx_full(1:num_vecs).*2-1;
idx_pick = sort([ idx_base, idx_base+1]);

% Draw chosen vectors in 2D
%drawcoords( vectors_full(:,idx_pick) );

% Rectify using N_a and d
plane_a = iter2plane([d_a(1),N_a']);
C_a = find_real_world_points( vectors_full(:,idx_pick), plane_a);

% Rectify using N_e and d
plane_e = iter2plane([d,N_e']);
C_e = find_real_world_points( vectors_full(:,idx_pick), plane_e);
if in3d,
    % attempt to normalise vectors
    [mu_a,sd_a,~] = findLengthDist( C_a, 0 );
    [mu_e,sd_e,~] = findLengthDist( C_e, 0 );

    ratio = mu_e/mu_a;

    C_a_norm = C_a * ratio;

    % Rotate all points by 90 degrees in z
    rotz = makehgtform('zrotate',deg2rad(-36));
    C_e_rot = zeros(3,size(C_e,2));
    for i=1:size(C_e,2),
        C_e_rot(:,i) = rotz(1:3,1:3)*C_e(:,i);
    end
    % Need to find centroids of each *actual* vector, and of each estimated.
    centroids_a = zeros(3,num_vecs)/2;
    centroids_e = zeros(3,num_vecs)/2;
    num = 1;
    for i=1:2:size(C_a,2),
        % find mean of i, i+1
        centroids_a(:,num) = mean([C_a_norm(:,i), C_a_norm(:,i+1)],2 );
        centroids_e(:,num) = mean([C_e_rot(:,i), C_e_rot(:,i+1)],2 );
        num = num+1;
    end

    % for each centroid, find the translation of e onto a
    translations = centroids_e - centroids_a;

    % Now translate endpoints of each 'e' vector by centroid translation
    trans_e = zeros(3,num_vecs);
    num=1;
    for i=1:2:size(C_a,2),
        trans_e(:,num) = C_e_rot(:,i) - translations(:,(i+1)/2 );
        trans_e(:,num+1) = C_e_rot(:,i+1) - translations(:,(i+1)/2 );
        num = num+2;
    end
    % Overlay estimated onto actual
    figure
    [~,g1] = drawcoords3(C_a_norm, 'Overlay of Estimate Plane Vectors onto Ground Truth', 0, 'k');
    [~,g2] = drawcoords3(trans_e , 'Overlay of Estimate Plane Vectors onto Ground Truth', 0, 'g',0);
    
    %% draw
    set(get(get(g1,'Annotation'),'LegendInformation'),...
        'IconDisplayStyle','on'); 

    set(get(get(g2,'Annotation'),'LegendInformation'),...
        'IconDisplayStyle','on');
    legend('Ground Truth','Approximation','Camera Position' ) 

    mins = min([min(C_a_norm,[], 2), min(C_e,[], 2)],[],2);
    mins = min(mins,0);
    maxs = max([max(C_a_norm,[], 2), max(C_e,[], 2)],[],2);
    maxs = max(maxs,0);
    axis( [mins(1) maxs(1) mins(2) maxs(2) mins(3) maxs(3)] );
    % end draw
else
    C_a_norm = C_a * 1;
    
    [t_a,p_a] = anglesFromN(N_a);
    
    %% Find mean pos, and align to centre
    C_a_mu = mean(C_a_norm,2)
    Ttrans_a = makehgtform('translate',0-C_a_mu);

    %% rotate in x by -theta and z by -psi
    Trot_x_a = makehgtform('yrotate',-t_a);
    Trot_z_a = makehgtform('zrotate',-p_a);
    T_a = Trot_x_a*Trot_z_a;

    %% set rotated coords
    C_a_moved = zeros(3,size(C_a_norm,2));
    for i=1:size(C_a_norm,2),   
        homog_pt=T_a*[C_a_norm(:,i);1];
        C_a_moved(:,i) = homog_pt(1:3);
    end
    
    %% Rpt for estimated
    [t_e,p_e] = anglesFromN(N_e);

    %% rotate in x by -theta and z by -psi
    Trot_x_e = makehgtform('yrotate',-t_e);
    Trot_z_e = makehgtform('zrotate',-p_e);
    T_e = Trot_x_e*Trot_z_e;

    C_e_moved = zeros(3,size(C_e,2));
    for i=1:size(C_e,2),   
        homog_pt=T_e*[C_e(:,i);1];
        C_e_moved(:,i) = homog_pt(1:3);
    end

   
    %% now have corrected actual and estimated, so time to colocate the
    % points
    
    % Need to find centroids of each *actual* vector, and of each estimated.
    centroids_a = zeros(3,num_vecs)/2;
    centroids_e = zeros(3,num_vecs)/2;
    num = 1;
    for i=1:2:size(C_a,2),
        % find mean of i, i+1
        centroids_a(:,num) = mean([C_a_moved(:,i), C_a_moved(:,i+1)],2 );
        centroids_e(:,num) = mean([trans_e(:,i), trans_e(:,i+1)],2 );
        num = num+1;
    end
   
    
    
    %% for each centroid, find the translation of e onto a
    translations = centroids_e - centroids_a;

    %% Now translate endpoints of each 'e' vector by centroid translation
    num=1;
    for i=1:2:size(C_a,2),
        trans_e(:,num)   = trans_e(:,i)   - translations(:,(i+1)/2 );
        trans_e(:,num+1) = trans_e(:,i+1) - translations(:,(i+1)/2 );
        num = num+2;
    end
    
    
    drawcoords3(C_a_moved , '3DTEST', 1, 'k');
    drawcoords3(trans_e   , '3DTEST', 0, 'g');
    %% And finally, draw them
    drawcoords(C_a_moved , '2DTEST', 1, 'k');
    drawcoords(trans_e   , '2DTEST', 0, 'g');
    
end

    function best = getPCA( coords )
        % First, need to get all direction vectors
%         trans_vecs = zeros(3,size(coords,2));
%         for j=1:2:size(coords,2),
%             trans_vecs(:,j) = cross(coords(:,j),coords(:,j+1));
%         end
%         figure,scatter3( trans_vecs(1,:), trans_vecs(2,:), trans_vecs(3,:) );
%         hold on
        [pca_coeffs] = princomp( coords' );
        best = pca_coeffs(1,:);
    end
end