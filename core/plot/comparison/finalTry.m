function [dist,idx_pick,handles] = finalTry( N_a, N_e, imc, num_vecs, idx_pick )

    if size(N_a,2) > 3,
        C_a = N_a;
        N_a = planeFromPoints(C_a);
        
    else
        C_a = find_real_world_points( imc, iter2plane([1,N_a']) );
    end
    
    handles = struct([]);
    
    C_e = find_real_world_points( imc, iter2plane([1,N_e']) );    
%     
%     mirrot = makehgtform('yrotate',pi );
%     
%     C_e = make3D( mirrot*makeHomogenous(C_e));
    
%     [mua,~,~,f1] = findLengthDist( moveTo(C_a), 1 )
%     ax(1,:) = axis;
%     g1= get(f1,'CurrentAxes');
%     title('Actual Vector Length Distribution');
%     
%     
%     [mue,~,~,f2] = findLengthDist( rescaleCoords( moveTo(C_e), C_a ), 1 )
%     ax(2,:)  = axis;
%     g2= get(f2,'CurrentAxes');
%     
%     axis( g1, [0 max(ax(:,2)) 0 max(ax(:,4))] )
%     axis( g2, [0 max(ax(:,2)) 0 max(ax(:,4))] )
%     
%     title('Estimated Vector Length Distribution');
    
%     
    if nargin < 5,
        idx_full = randperm(size(imc,2)/2);
        idx_base = idx_full(1:num_vecs).*2-1;
        idx_pick = sort([ idx_base, idx_base+1]);
    end
%     
    handles(1).originalActual = drawcoords3( C_a,'Original Actual');
    handles(1).originalEstimate = drawcoords3( C_e,'Original Estimate',1,'r');
    % pause
%     C_a = C_a_full(:,idx_pick);
%     C_e = C_e_full(:,idx_pick);
% drawcoords3(rescaleCoords( moveTo(C_e), moveTo(C_a) ) ,'',0,'r');


    %% Rotate into x-y plane
    [t_a,p_a] = anglesFromN( N_a );
    [t_e,p_e] = anglesFromN( N_e );
    
    nrotx_a = makehgtform('xrotate',t_a);
    nrotz_a = makehgtform('zrotate',p_a);
    nrotx_e = makehgtform('xrotate',t_e);
    nrotz_e = makehgtform('zrotate',p_e);
    
    rect_pts_a = nrotx_a*nrotz_a*[C_a;ones(1,size(C_a,2))];
    rect_pts_a = moveTo(rect_pts_a(1:3,:));
    rect_pts_a(3,:) = 0;
    


    rect_pts_e = nrotx_e*nrotz_e*makeHomogenous(C_e);
    rect_pts_e = moveTo(rect_pts_e(1:3,:));
  %   rect_pts_e(3,:) = 0;
    
    pts_a = moveTo(rect_pts_a(:,:));
    pts_e = rescaleCoords( moveTo(rect_pts_e(:,:)), rect_pts_a(:,:) );
    
    
    handles(1).onPlaneActual = drawcoords(rect_pts_a(:,idx_pick), 'Actual Moved to Plane');    
    handles(1).onPlaneEstimate = drawcoords3(rect_pts_e(:,idx_pick) , 'Estimate Moved to Plane',1,'r');
    % pause
    
    % BEFORE MIRRORING
    disp('Rotating')
    aligned = rect_pts_e;
        
        [psi,mindist] = climbToPsi( aligned,rect_pts_a, idx_pick );
     
        
        rot = makehgtform('zrotate',psi);
        aligned = moveTo(make3D(rot*makeHomogenous( aligned )));
        
    mirrot = makehgtform('yrotate',pi );
    aligned_mir = make3D(mirrot*makeHomogenous(rect_pts_e));
    disp('Rotating Mirrored')
        
        [psi2,mindist2] = climbToPsi( aligned_mir,rect_pts_a, idx_pick )
     
        rot2 = makehgtform('zrotate',psi2);
        aligned_mir = moveTo(make3D(rot2*makeHomogenous( aligned_mir )));
    
    disp('****** MINIMUM DISTANCES ******')
    format long
    mindist,mindist2
    format short
    disp('*******************************')
    if mindist2 > mindist,
%         aligned = aligned_mir;
        disp('Mirroring');
    end
    

    % Align using mirrored coords
    A_final = moveTo(rect_pts_a(:,idx_pick));
    E_final = rescaleCoords( heavyMoveTo(aligned_mir(:,idx_pick)), A_final );   
    handles(1).finalComparison = drawcoords(A_final);    
    drawcoords(E_final,'',0,'r');
    title('Alignment with mirroring');
    
    % Align using non-mirrored coords
    A_final = moveTo(rect_pts_a(:,idx_pick));
    E_final = rescaleCoords( heavyMoveTo(aligned(:,idx_pick)), A_final );
    handles(1).finalComparison2 = drawcoords(A_final);    
    drawcoords(E_final,'',0,'r');
    title('Alignment without mirroring');
%   
    dist = 0;
    for i=1:size(A_final,2),
%         plot( [A_final(1,i),E_final(1,i)],[A_final(2,i),E_final(2,i)],'b')
        dist = dist+vector_dist(A_final(:,i),E_final(:,i));
    end


    
    function [rot,psi] = rotFromCorresp( p_a,p_e, notim )
        % Input:
        %   p_a    Pair of points on known plane
        %   p_a    Pair of points on estim plane
        
        if nargin < 3,
            notim = 0;
        end
        
        x1 = p_a(1);
        y1 = p_a(2);
        x2 = p_e(1);
        y2 = p_e(2);
        
        alpha = x1/y1;
        
        b = (alpha*y2 - x2) / ( -alpha*x1 - y1 );
        psi = asin(b);
        
        if iscomplex(psi),            
            x2 = p_a(1);
            y2 = p_a(2);
            x1 = p_e(1);
            y1 = p_e(2);

            alpha = x1/y1;

            b = (x1*y2 - x2*y1) / ( x1^2 + y1^2 );
            psi = asin(b);
        end
        rot = makehgtform('zrotate',psi);
    end

    function C_o = moveTo( C, P )
        if nargin < 2,
            P = [0;0;0];
        end
        
        maxs = max(C,[],2);
        mins = min(C,[],2);
        C_av = mean( [maxs,mins], 2 );
        
        C_o = C - repmat(C_av,1, size(C,2)) + repmat(P,1, size(C,2)) ;
    end
    
    
    function [C_s,k] = rescaleCoords( C_e, C_a )
        [mu_a,sd_a,lensa] = findLengthDist( C_a, 0 );
        f1=find( lensa > mu_a+sd_a );
        f2=find( lensa < mu_a-sd_a );
        bad_idx=union( f1,f2 );
        lensa(bad_idx) = [];
        numua = mean(lensa );
%         title('actual')
        [mu_e,sd_e,lense] = findLengthDist( C_e, 0 );
        f1=find( lense > mu_e+sd_e );
        f2=find( lense < mu_e-sd_e );
        bad_idx=union( f1,f2 );
        lense(bad_idx) = [];
        numue = mean(lense );
%         title('est')
        k = mu_a/mu_e;

        C_s = C_e*k;
    end

    function c4 = make4D(c)
        c4 = [c;ones(1,size(c,2))];
    end
    function c3 = make3D(c)
        c3 = c(1:3,:);
    end

    function te = heavyMoveTo(e,a)
        
        % find step size (maxe-mine)/100
        mxe = max(e(1:2,:), [], 2);
        mne = min(e(1:2,:), [] ,2);
        te = moveTo(e);;
        
        step_size = abs( mxe - mne ) ./ 100;
        
%         for x=0:step_size:
    end
   
    function [psi,mindist] =  climbToPsi( rect_pts_e,rect_pts_a,idxs  )
         % work out rotation
        rng = 0:360;
        dists = zeros(1,length(rng));
%         h = waitbar( length(rng), sprintf('About to run %d rotations', length(rng)) );
        for i=1:length(rng),
%             waitbar( i/length(rng), h, sprintf('Iteration: %d of %d (%d%%)', i, length(rng), round(i/length(rng) * 100) ));
            r   = makehgtform('zrotate',deg2rad(rng(i)));
            tmp = r * makeHomogenous( rect_pts_e );
            a_rs = rescaleCoords( moveTo(rect_pts_a(1:3,idxs)), tmp(1:3,idxs) );
            tmp2 = moveTo(tmp(1:3,idxs));
            for j=1:size(tmp2,2),
                dists(i) = dists(i) + vector_dist(a_rs(1:3,j),tmp2(1:3,j));              
            end             
        end

%         delete(h)
        [mindist,minidx]=min(dists);
        figure;
        scatter(rng, dists);
        l=line([rng(minidx),rng(minidx)],[min(dists),max(dists)]);
        set(l,'Color','r');
        xlabel('Rotation angle, degrees'); ylabel('Sum euclidean distance between actual and estimated endpoints');
%         if nargin == 3,
%             title(sprintf('Rotation against sum euclidean distance. Iteration %d', num ));
%         end

        psi = deg2rad(rng(minidx));
    end

end
