function [ ls, E, E_l ] = getDError( num_tests )

    if nargin < 1
        num_tests = 1000;
    end

    l = 175;

    d = 5000;
    
    E = zeros(5,num_tests+1);
    E_l = zeros(5,num_tests+1);

    % Fixed n, now need to put D into equation and look at the errors
    
    f = figure,
    j = 1;
    for i=0:30:180,
       % for x=-0.1:0.05:0.1,
            if i == 90, 
                continue;
            end
            [n, ~, im_coords] = make_test_data( i, d, l, 0.05 );

            step_size = (d*2) / num_tests;
            ls = zeros( 3, num_tests+1 );

            ds = 0:step_size:d*2;

            ls(1,:) = arrayfun( @(x) dist_eqn_find_l([ x,n'],im_coords(:,1:2)), ds);
            ls(2,:) = arrayfun( @(x) dist_eqn_find_l([ x,n'],im_coords(:,3:4)), ds);
            ls(3,:) = arrayfun( @(x) dist_eqn_find_l([ x,n'],im_coords(:,5:6)), ds);


            E_l(j,:) = sum((ls - l).^2,1);
            E(j,:) = var(ls, 0, 1);



            step_size = (d*2) / num_tests;
            subplot(3,2,j);
            scatter( 0:step_size:(d*2), E_l(j,:), 'b*' );
            xlabel( 'D Input');
            ylabel( 'Error from actual l' );
            title( sprintf('l of %d and d of %d n=(%.3f, %.3f, %.3f), theta=%d', l, d, n(1),n(2),n(3), i ) );
            j = j + 1;
       % end
    end
end
