function trytoiterate( coords )

    % work up from d = 0:50:5000
    % Increase theta
    disp( 'Running' );
    
    ds = -100:50:100;
    thetas = -120:10:120;
    x0 = zeros( size(ds,2)* size(thetas,2) , 4 );
    num = 1;
    
    d_axis = zeros( 1, size(ds,2)* size(thetas,2) );
    t_axis = zeros( 1, size(ds,2)* size(thetas,2) );
    
    for d=ds,
        for theta=thetas,
            d_axis(num) = d;
            t_axis(num) = theta;
            n = [0, sin(deg2rad(theta)), cos(deg2rad(theta)) ];      % Create a normal
            n0 = n ./ sqrt(n(1)^2 + n(2)^2 + n(3)^2);   
            x0(num,:) = [ d, n0 ];
            num = num + 1;
        end
    end
    
    num_x0s = size(x0,1)
    
    errors = zeros(1,num_x0s);
    passes = zeros(1,num_x0s);
    planes = zeros(num_x0s,4);
    
    for x=1:num_x0s,
        
        fprintf( 'Attempt %d: ', x );
        [gp_coords, gp_plane, pass] = iterate_to_gp( coords, x0(x,:) );
        
        planes(x,:) = gp_plane;
        
        errors(x) = getlength_L2Error( gp_coords );  
        passes(x) = pass;
    end
    save gp_iteration_results.mat d_axis t_axis errors passes planes
    
    figure,
    scatter3( d_axis, t_axis, errors );
    xlabel( 'Intial d');
    ylabel( 'Initial t' );
    zlabel( 'L2 Error Measure' );
    
    
    
end
    
    

