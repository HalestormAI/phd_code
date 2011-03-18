function [idx_pick,ls_vecs]= newComparison( N_a, N_e, d_e, imc, num_vecs, NUM_LS, idx_pick, ls_vecs )
    if nargin <  6,
        NUM_LS = 3;
    end
    % Find d for GT from n and coords;
    d_a = max(findDFromNandImage( N_a, imc ));

    if nargin < 7,
        % Need to pick some display vectors
        idx_full = randperm(size(imc,2)/2);
        idx_base = idx_full(1:num_vecs).*2-1;
        idx_pick = sort([ idx_base, idx_base+1]);
    end
    % Rectify using N_a and d
    plane_a = iter2plane([d_a,N_a']);
    C_a = find_real_world_points( imc(:,idx_pick), plane_a);
    
    
    %% FIND ACTUAL ROTATION
    if nargin < 8,
        % Now pick 3 for Linear System
        idx_full = randperm(size(C_a,2));
        ls_vecs = idx_full(1:NUM_LS);
    end
    
    % Subset of 3 vectors for LDS
    C_ls_a = C_a(:,ls_vecs);
    
    X = testMyElim( C_ls_a );
% 
%     % SVD (only need last col of V matrix)
%     [U,D,V] = svd(C_ls_a,0)
%     
%     X = V(:,3)
    
    a=X(1);
    b=X(2);
    c=X(3);
    
    % So, X = [ a, b, c ]', can solve theta instantly from c:
    % a = sin(theta)sin(phi)
    % b = -sin(theta)cos(phi)
    % c = cos(theta)

%     
    % Build Rotation Matrices the matlab way
    phi   = asin( a )
    theta = acos( c / cos(phi) ) 
     psi = 0;
    xrot = makehgtform('xrotate', phi   );
    yrot = makehgtform('yrotate', theta );
   zrot = makehgtform('zrotate', psi   );

    
    compound = xrot*yrot*zrot
    inv(compound)
    transpose(compound)
   C_a_rot = transpose(compound)*[C_a;ones(1,size(C_a,2))];
   C_a_rot = C_a_rot(1:3,:);

% Euler angles
% http://www.eng.buffalo.edu/~kofke/ce530/Lectures/Lecture17/sld010.htm
%     theta = acos( c ) 
%     phi   = asin( a / sin( theta ) )
%     psi = 0;
%     compound = [ cos(psi)*cos(phi) - cos(theta)*sin(phi)*sin(psi), ...
%                  cos(psi)*sin(phi) + cos(theta)*cos(phi)*sin(psi), ...
%                  sin(psi)*sin(theta); ...
%                 -sin(psi)*cos(phi) - cos(theta)*sin(phi)*cos(psi), ...
%                 -sin(psi)*sin(phi) + cos(theta)*cos(phi)*cos(psi), ...
%                  cos(psi)*sin(theta); ...
%                  sin(theta)*sin(phi), ...
%                 -sin(theta)*cos(phi), ...
%                  cos(theta) ]
% C_a_rot = compound*C_a;

% Another way
% http://homepages.inf.ed.ac.uk/rbf/CVonline/LOCAL_COPIES/MARBLE/high/pose/
% express.htm
%     theta = asin( -a ) 
%     phi   = acos( c / cos( theta ) )
%     psi = 0;
%     compound = [ cos(theta)*cos(psi), ...
%                 sin(phi)*sin(theta)*cos(psi) - cos(phi)*sin(psi), ...
%                 cos(phi)*sin(theta)*cos(psi) + sin(phi)*sin(psi); ...
%                 cos(theta)*sin(psi), ...
%                 sin(phi)*sin(theta)*sin(psi) - cos(phi)*cos(psi), ...
%                 cos(phi)*sin(theta)*sin(psi) + sin(phi)*cos(psi); ...
%                 -sin(theta), ...
%                 sin(phi)*cos(theta),...
%                 cos(phi)*cos(theta) ];
% % 
%     % Apply rotation to vectors
%     C_a_rot =   compound*C_a
%     
    
    % Move to origin and rescale them to the same mu(l)
    C_a_o = moveTo( C_a );
    C_a_ro = rescaleCoords(moveTo( C_a_rot ), C_a_o );

    % Draw
    drawcoords3( C_a_o ); grid on
    drawcoords3( C_a_ro, '', 0,'b' );

    function C_o = moveTo( C, P )
        if nargin < 2,
            P = [0;0;0];
        end
        
        C_av = mean( C, 2 );
        
        C_o = C - repmat(C_av,1, size(C,2)) + repmat(P,1, size(C,2)) ;
    end

    function C_s = rescaleCoords( C_e, C_a )
        [mu_a,~,~] = findLengthDist( C_a, 0 )
%         title('actual')
        [mu_e,~,~] = findLengthDist( C_e, 0 )
%         title('est')
        k = mu_a/mu_e;

        C_s = C_e*k;
    end
end