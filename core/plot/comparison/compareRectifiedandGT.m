function [idx_pick] = compareRectifiedandGT( N_a, N_e, d, num_vecs, vectors_full, exp_id )


% Find d's to approximate equal scale;
d_a = findDFromNandImage( N_a, vectors_full );

[t_a,p_a] = anglesFromN( N_a )
[t_e,p_e] = anglesFromN( N_e )

% Need to pick, for example 30 vectors
idx_full = randperm(size(vectors_full,2)/2);
idx_base = idx_full(1:num_vecs).*2-1;
idx_pick = sort([ idx_base, idx_base+1]);

% drawcoords(vectors_full(:,idx_pick))
%% Get 3D points using image coords and planes
% Rectify using N_a and d
plane_a = iter2plane([d,N_a']);
C_a = find_real_world_points( vectors_full(:,idx_pick), plane_a);

% Rectify using N_e and d
plane_e = iter2plane([d,N_e']);
C_e = find_real_world_points( vectors_full(:,idx_pick), plane_e);


        [mu_a,~,~] = findLengthDist( C_a, 0 );
        [mu_e,~,~] = findLengthDist( C_e, 0 );

[~,g1] = drawcoords3(C_a, 'Initial, Actual', 1, 'k');
[~,g1] = drawcoords3(C_a, 'Initial, Estimated', 1, 'g');

%% Rotate Actual to x-y plane
rotz_a = makehgtform( 'zrotate',p_a );
C_a_rot = rotz_a(1:3,1:3)*C_a;
% [~,g1] = drawcoords3(C_a_rot, 'Actual after z', 1, 'k');

rotx_a = makehgtform( 'xrotate',t_a );
C_a_rot2 = rotx_a(1:3,1:3)*C_a_rot;
[~,g1] = drawcoords3(C_a_rot2, 'Actual after x', 1, 'k');

%% Now Repeat for Estimated
org_e = moveTo( C_e );

rotz_e = makehgtform( 'zrotate',p_e );
C_e_rot = rotz_e(1:3,1:3)*C_e;

rotx_e = makehgtform( 'xrotate',t_e );
C_e_rot2 = rotx_e(1:3,1:3)*C_e_rot;

C_eo = moveTo(C_e_rot2);
C_ao = moveTo(C_a_rot2);

C_es = rescaleCoords( C_eo, C_ao );

%% Draw

f = figure,
[~,g1] = drawcoords3(C_ao, '3D Overlay of Actual Plane Vectors onto Ground Truth', 0, 'k');
[~,g2] = drawcoords3(C_es, '3D Overlay of Estimate Plane Vectors onto Ground Truth', 1, 'g');
mins = min( [min( C_es,[],2 ), min( C_ao,[],2 ) ],[],2);
maxs = max( [max( C_es,[],2 ), max( C_ao,[],2 ) ],[],2);
axis( [ mins(1) maxs(1) mins(2) maxs(2) -5 5 ] )

figure
[~,g1] = drawcoords(C_ao, '2D Overlay of Actual Plane Vectors onto Ground Truth', 0, 'k');
[~,g2] = drawcoords(C_es, '2D Overlay of Estimate Plane Vectors onto Ground Truth', 0, 'g');

%[~,g2] = drawcoords3(C_e_origin , '3D Overlay of Estimate Plane Vectors onto Ground Truth', 0, 'g',0,'*');
% figure
% [~,g1] = drawcoords(C_a_rot(1:2,:), '2D Overlay of Estimate Plane Vectors onto Ground Truth', 0, 'k');
% [~,g2] = drawcoords(C_e_rot(1:2,:) , '2D Overlay of Estimate Plane Vectors onto Ground Truth', 0, 'g',0,'*');

set(get(get(g1,'Annotation'),'LegendInformation'),...
     'IconDisplayStyle','on'); 
 
 set(get(get(g2,'Annotation'),'LegendInformation'),...
     'IconDisplayStyle','on');
 
 legend('Original','Xrotate') 
 
if nargin == 6,
    % get folder name
    fname_output = sprintf('%s/experiment_%d_planes.fig',datestr(now, 'dd-mm-yy'),exp_id);
    saveas(f,fname_output,'fig');
end



    function C_o = moveTo( C, P )
        if nargin < 2,
            P = [0;0;0];
        end
        
        C_av = mean( C, 2 );
        
        C_o = C - repmat(C_av,1, size(C,2)) + repmat(P,1, size(C,2)) ;
    end

    function C_s = rescaleCoords( C_e, C_a )
        [mu_a,~,~] = findLengthDist( C_a, 1 )
        title('actual')
        [mu_e,~,~] = findLengthDist( C_e, 1 )
        title('est')
        k = mu_a/mu_e

        C_s = C_e*k;
    end


end
