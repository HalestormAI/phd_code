function [ angles, pass, normals ] = test_d_stability_vid( im_coords, image, H, n, d_range )

    % Ensure n is a column vector
    if min(size(n)) ~= 1,
        exception = MException('ResultChk:BadInput', 'n must be a column vector.');
        throw(exception);
    end
    if iscol( n ),
        n = n';
    end
    
    if nargin < 5,
        d_range = 0.5:0.5:100;
    end

    figure,
    imagesc( image );
    drawcoords( im_coords, '', 0, 'k' );
    
    % Find n from homography
    correct_ns = findNormalFromH( H );
    
    normals = zeros( max(size(d_range)), 3 );
    angles = zeros( max(size(d_range)), 2 );
    pass = zeros( max(size(d_range)), 1 );
    
    
    num = 1;
    
    h = waitbar(0,'Starting...', 'Name', sprintf('%d iterations', max(size(d_range))));
    for d=d_range,
        waitbar(num / max(size(d_range)), h, sprintf('Running Iteration: %d (%d%%)',num, round((num / max(size(d_range))) * 100)));

        x0 = [ d, n ];
        try
            [ ~, x_iter, ~ ] = iterate_to_gp_video( im_coords, x0, 3, 'MAXDIST', 0 );
            normals(num,:) = x_iter(2:4);
            angles(num,1) =  90-abs(90-rad2deg( acos(dot( x_iter(2:4), correct_ns.a ))));
            angles(num,2) =  90-abs(90-rad2deg( acos(dot( x_iter(2:4), correct_ns.b ))));
            pass(num) = 1;
        catch
            pass(num) = 0;
        end
        num = num + 1;
        
    end
    delete(h)
    figure, scatter( d_range, angles(:,1) );
    title('Angle of plane against n_a for varying d');
    figure, scatter( d_range, angles(:,2) );
    title('Angle of plane against n_b for varying d');
    figure, scatter( d_range, pass );
    title('Passes for varying d');
    