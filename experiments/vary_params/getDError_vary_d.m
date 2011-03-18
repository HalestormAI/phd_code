function [ ls, E, E_l ] = getDError_vary_d( num_tests )

    if nargin < 1
        num_tests = 1000;
    end

    l = 175;

    Ds = [ 0.5 50 500 5000 50000 ];
    
    E = zeros(5,num_tests+1);
    E_l = zeros(5,num_tests+1);

    % Fixed n, now need to put D into equation and look at the errors
    figure,
    for j=1:size(Ds,2),


        d = Ds(j);
     
        [n, coords, im_coords] = make_test_data( 120, d, l );
        
        step_size = (d*2) / num_tests;
        ls = zeros( 3, num_tests+1 );
        
        ds = 0:step_size:d*2;
        
        ls(1,:) = arrayfun( @(x) dist_eqn_find_l([ x,n'],im_coords(:,1:2)), ds);
        ls(2,:) = arrayfun( @(x) dist_eqn_find_l([ x,n'],im_coords(:,3:4)), ds);
        ls(3,:) = arrayfun( @(x) dist_eqn_find_l([ x,n'],im_coords(:,5:6)), ds);
        
                
        E_l(j,:) = sum((ls - l).^2,1);
        E(j,:) = var(ls, 0, 1);
        
        subplot(3,2,j);
        scatter( 0:step_size:(d*2), E(j,:), 'b*' );
        xlabel( 'D Input');
        ylabel( 'Variance in  l' );
        title( sprintf('Variance in ls with given d and correct d of %d (l = %d)', d ,l  ) );
    end
    
    
        figure,
    for j=1:size(Ds,2),
        d = Ds(j);
        step_size = (d*2) / num_tests;
        subplot(3,2,j);
        scatter( 0:step_size:(d*2), E_l(j,:), 'b*' );
        xlabel( 'D Input');
        ylabel( 'Error from actual l' );
        title( sprintf('Error incurred in l against d for l of %d and d of %d', l, d ) );
    end
end