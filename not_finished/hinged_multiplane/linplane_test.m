function [best_normal, best_d, errors, normals, ds, M] = linplane_test( theplanes, traj_plane2, rng_num, boundary_line )

    if nargin < 4 || isempty(boundary_line)
        boundary_line = theplanes(1).camera(:,3:4);
    end

    n1 = planeFromPoints(theplanes(1).camera,[],2);
    n2 = planeFromPoints( [boundary_line,[0;0;0]],3,2);

    ref_planes(:,1) = n1;
    ref_planes(:,2) = n2;
    
    if nargin < 3 || isempty(rng_num)
        rng_num = -1:0.02:1;
    end

    errors = cell(length(rng_num),1);

    if nargout >= 6 
        figure;
    end

    
    normals = cell(length(rng_num),length(rng_num));
    ds      = zeros(length(rng_num),length(rng_num));
    
    imc_plane2 = cellfun(@(x) traj2imc(x,1,1), traj_plane2,'un',0)
    
    for i=1:length(rng_num);
        for j=1:length(rng_num);
            
            if(rng_num(i) == 0 && rng_num(j) == 0) 
                errors{i,j} = Inf;
                normals{i,j} = [Inf;Inf;Inf];
                ds(i,j) = Inf;
                continue;
            end
            fprintf( 'Running line %d of %d in set %d of %d.\n',j, length(rng_num), i, length(rng_num));
            [new_n, new_d] = multiplane_linear_combination2( ref_planes, [rng_num(i),rng_num(j)], boundary_line(:,1) );
        %     new_d = norm(new_n);
        %     rect = backproj_c( new_n, new_d, 0.0013, sideTrajectories{1} );

            [errors{i,j},~,~, rectTrajectories] = errorfunc( new_n, [new_d, 0.0014], imc_plane2, 0, @backproj_n );
            normals{i,j} = new_n;
            ds(i,j) = new_d;

            

            pln = backproj_n(new_n, [new_d 0.0014], theplanes(2).image );
            boundary_line_2 = pln(:,2:-1:1);

            if nargout >= 6 
                clf
                drawPlane(theplanes(1).camera,'',0,'k');
                drawPlane(pln,'',0,'r');
    %             drawtraj(rectTrajectories,'',0,'b');
                plot3(boundary_line(1,:),boundary_line(2,:),boundary_line(3,:),'g-','LineWidth',4)
                plot3(boundary_line_2(1,:),boundary_line_2(2,:),boundary_line_2(3,:),'m--','LineWidth',4)
                view(-51,8);
                M( (i-1)*length(rng_num) + j ) = getframe(gcf);
            end
    %         pause

        end
    end
    
    ssderrors = cellfun(@(x) sum(x.^2), errors);
    [~,minidx] = min(ssderrors(:));
    
    [ I,J ] = ind2sub(size(errors),minidx);
    
    best_normal = normals{I,J};
    best_d      = ds(I,J);
    

end