function [ wc, x_iter, ids_full, debug_info, x0 ] = iterate_to_gp_video( im_coords, x0, NUM_RANDOMS, point_sampling, graphs )
% Uses the L-V algorithm to estimate the ground-plane parameters.
%
%   INPUT:
%       im_coords   A set of 2D motion vector endpoints (consecutive pairs)
%       x0          An inital condition
%       NUM_RANDOMS How many vectors should be used in the estimation?
%
%   OUTPUT:
%       wc          A set of 3D estimated world coordinates
%       x_iter      Result of the final iteration - estimated plane params
%       ids_full    Indices of the coordinates that were used


    if nargin < 2,
        n = normalFromAngle( deg2rad(45), deg2rad(5) );
        n0 = n ./ norm(n);

        x0 = [ 10, n0' ];
    end
    if nargin < 3,
        NUM_RANDOMS = 3;
    end
    if nargin < 4,
        point_sampling = 'MONTECARLO';
    end
    if nargin < 5,
        graphs = 1;
    end
    
    BAD_THRESH = 2;
    PROPORTION = 6;
    
        options = optimset( 'Display', 'off', 'Algorithm', {'levenberg-marquardt',0.001}, 'MaxFunEvals', 100000, 'MaxIter', 1000000, 'TolFun',1e-9,'ScaleProblem','Jacobian' );

    done = 0;
    attempts = 0;
    while ~done,
        if mod(attempts,20) == 0,
            %disp('Selecting coord set...')
            if isa(point_sampling,'double'),
                ids_full = point_sampling;
            elseif strcmp(point_sampling, 'MAXDIST'),
                if attempts == 0 && graphs,
                    ids_full = maxPaths( im_coords, NUM_RANDOMS,0.01,1 );
                else
                    ids_full = maxPaths( im_coords, NUM_RANDOMS,0.01,0 );
                end
            elseif strcmp(point_sampling, 'MONTECARLO'),

                ids_full = monteCarloPaths( im_coords, NUM_RANDOMS,3,50 );
            else
                 r = randperm(size(im_coords,2)/2);
                 ids = r(1:NUM_RANDOMS) .* 2 -1;
                 ids_full = sort( [ ids, (ids + 1) ] );
            end
        end

    %     for i=1:NUM_RANDOMS,
    %         r = randperm(size(im_coords,2)/2);
    %         % r = sort( randi(size(im_coords,2)/2, 1,NUM_RANDOMS) );
    %         ids = r(1:NUM_RANDOMS) .* 2 -1;
    %         ids_full = sort( [ ids, (ids + 1) ] );
    %         possible_points(i,:) = ids_full;
            
    %         % Find midpoints of lines
    %         midpoints = (im_coords( ids ) + im_coords( ids + 1 )) ./ 2;
    %     end
    %    used_coords = im_coords( :, ids_full );

       % used_coords = [ im_coords(:,id1:id1+1), im_coords(:,id2:id2+1), im_coords(:,id3:id3+1) ];
        [ x_iter, fval, exitflag, output ] = fsolve( @gp_iter_func, x0, options, im_coords(:,ids_full) )
        iters = output.iterations;
        if exitflag < 1,
             if strcmp(point_sampling , 'MAXDIST') && attempts > 100,
                 disp('Trying montecarlo sampling in the hope of finding some answer.');
                 point_sampling = 'MONTECARLO';
             elseif strcmp(point_sampling , 'MONTECARLO') && attempts > 200,
                 disp('Trying random sampling in the hope of finding some answer.');
                 point_sampling = 'RANDOM';
             end
                
            attempts = attempts + 1;
            if (attempts) > 100,
                exception = MException('AcctError:Incomplete', sprintf('Failed after 10 attempts. All is lost. I give up'));
            %    throw(exception);
            end
                x0 = generateNormal( )  ;    % Create a normal
        else
            

            plane = struct('n', x_iter(2:4)', 'd', x_iter(1));
            wc = find_real_world_points( im_coords, plane );
           rect_speeds = speedDistFromCoords( wc );

            howmany = size(find(rect_speeds > mean(rect_speeds) + PROPORTION*std(rect_speeds)),2);
            [validn, validd] = checkPlaneValidity( x_iter );
%             
%             if ~validn ,
%                % disp('Invalid n generated. Reconfiguring.');
%                 x_iter;
%                 validn;
%                 x0 = generateNormal( ) ;     % Create a normal
%                 attempts = attempts + 1;
%                 continue;
%             end
            
            if howmany < BAD_THRESH,
                done = 1
                if graphs,
                    drawcoords(im_coords)
                    scatter(im_coords(1,ids_full),im_coords(2,ids_full),12,'g*')
                    figure,
                    mins = min( [min(wc,[],2),min(wc,[],2)], [], 2 );
                    maxs = max( [max(wc,[],2),max(wc,[],2)], [], 2 );
                    ezmesh(@(x,y)getCartesianPlane(x,y,x_iter(1),x_iter(2:4)',wc),[mins(1) maxs(1) mins(2) maxs(2)]);
                    colormap([0.5,0.5,0.5]);
                    drawcoords3( wc, 'Estimated Coordinates from video.', 0, 'r');
                end
                debug_info = struct('attempts',attempts,'iterations',iters, 'exitFlag', exitflag );
            
            else
              %  exception = MException('AcctError:Incomplete', sprintf('%d bad points. This is too many.', howmany ));
              %  disp( exception.message  );  
                x0 = generateNormal( )   ;   % Create a normal
                attempts = attempts + 1;
            end
                
        end
    end

    
end
