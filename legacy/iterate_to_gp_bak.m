function [ wc, x_iter ] = iterate_to_gp( im_coords )

    n = [0, sin(deg2rad(45)), cos(deg2rad(45)) ];      % Create a normal
    n0 = n ./ sqrt(n(1)^2 + n(2)^2 + n(3)^2);
    
    x0 = [ 3000, n0 ];
    
    % Pick 3 pairs at random
    
    id1 = randi(round(size(im_coords,2)/2),1);
    id2 = randi(round(size(im_coords,2)/2),1);
    while 1==1,
        if id2 == id1,
            id2 = randi(round(size(im_coords,2)/2),1);
        else
            break
        end            
    end
    id3 = randi(round(size(im_coords,2)/2),1);
    while 1==1,
        if id3 == id1 || id3 == id2,
            id3 = randi(round(size(im_coords,2)/2),1);
        else
            break
        end            
    end
    id1 = id1*2-1;
    id2 = id2*2-1;
    id3 = id3*2-1;
    
    used_coords = [ im_coords(:,id1:id1+1), im_coords(:,id2:id2+1), im_coords(:,id3:id3+1) ];
    
    options = optimset( 'Display', 'off', 'Algorithm', {'levenberg-marquardt',.001}, 'MaxFunEvals', 100000, 'MaxIter', 1000000, 'TolFun',1e-10,'ScaleProblem','Jacobian' );
    [ x_iter, fval, exitflag, output ] = fsolve( @gp_iter_func, x0, options, used_coords );
    
    iters = output.iterations;
    if exitflag < 1,
        x_iter;
        exitflag;
         exception = MException('AcctError:Incomplete', sprintf('Did not converge in %d iterations. Exitflag: %d.', iters, exitflag ));

    	throw( exception  );
    end
    
    plane = struct('n', x0(2:4)', 'd', x0(1));
       
    wc = find_real_world_points( im_coords, plane );
    
end
