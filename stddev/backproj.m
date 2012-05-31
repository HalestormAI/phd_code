function rectTraj = backproj( orientation, scales, traj )
      
    % orientation consists of theta and psi
    abc   = normalFromAngle( -orientation(1), -orientation(2),'degrees' );

    d     = scales(1);
    alpha = scales(2);

    rectTraj = zeros(3,size(traj,2));

    for i=1:size(traj,2)
        rectTraj(:,i) = backproj_point( abc, d, alpha, traj(:,i));
    end


    function p = backproj_point( abc, d, alpha, point )
        a = abc(1);
        b = abc(2);
        c = abc(3);

        Z =  d / (alpha*point(1)*a + alpha*point(2)*b + c);
        
        X = alpha*point(1)*Z;
        Y = alpha*point(2)*Z;

        p = [X;Y;Z];
    end

end
