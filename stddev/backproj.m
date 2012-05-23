function rectTraj = backproj( params, constants, traj )
    
    % TODO: Perform back projection onto camera plane using estimated & constants.
  
    % params consists of theta and psi
    abc   = normalFromAngle( -params(1), -params(2),'degrees' );
    %params;

    d     = constants(1);
    alpha = constants(2);

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
