function [best_normal, best_d, errors, normals, ds, M] = linplane_test( planes, traj_plane2, rng_num )

    boundary_line = planes(1).camera(:,3:4);

    n1 = planeFromPoints(planes(1).camera,[],2);
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

    
    normals = zeros(3,length(rng_num));
    ds      = zeros(1,length(rng_num));
    for i=1:length(rng_num);
        [new_n, new_d] = multiplane_linear_combination2( ref_planes, [1,rng_num(i)], boundary_line(:,1) );
    %     new_d = norm(new_n);
    %     rect = backproj_c( new_n, new_d, 0.0013, sideTrajectories{1} );

        [errors{i},~,~, rectTrajectories] = errorfunc( new_n, [new_d, 0.0014], traj2imc(traj_plane2), 0, @backproj_n );
        normals(:,i) = new_n;
        ds(i) = new_d;

        fprintf( 'Running line %d of %d.\n',i, length(rng_num));

        pln = backproj_n(new_n, [new_d 0.0014], planes(2).image );
        boundary_line_2 = pln(:,2:-1:1);
        
        if nargout >= 6 
            clf
            drawPlane(planes(1).camera,'',0,'k');
            drawPlane(pln,'',0,'r');
            drawtraj(rectTrajectories,'',0,'b');
            plot3(boundary_line(1,:),boundary_line(2,:),boundary_line(3,:),'g-','LineWidth',4)
            plot3(boundary_line_2(1,:),boundary_line_2(2,:),boundary_line_2(3,:),'m--','LineWidth',4)
            view(0,-30);
            M(i) = getframe(gcf);
        end
%         pause

    end
    
    ssderrors = cellfun(@(x) sum(x.^2), errors);
    [~,minidx] = min(ssderrors);
    best_normal = normals(:,minidx);
    best_d      = ds(minidx);
    

end