function [angles,angarr,planes,failReason,result,im_ids] = examineX0Effect_video( im_coords, H, DELTA, vidname, img )

if ~exist('DELTA','var'),
    DELTA = input('Input Selection DELTA: ');
end



coords = H*makeHomogenous( im_coords );

% Find same length vectors and select 3.
[ids_full,usable,im_ids] = pickIds( coords, im_coords, DELTA );


% Build file name data
fld = sprintf( 'x0_effect_video/%s/%s', vidname, getTodaysFolder() );
if ~exist(fld,'dir'),
    mkdir( fld );
end
a        = dir(sprintf('./%s/x0_converge_DELTA=%.3d_run*.fig',fld,DELTA));
next_id  = size(a,1) + 1;

fname = sprintf('%s/x0_converge_DELTA=%.3d_run%d', fld, DELTA, next_id )

saveas(gcf, strcat(fname,'_chosen','.fig'));
close( gcf );

% Create and save image showing used coords
figure
imagesc(img);
drawcoords( im_coords, '', 0, 'b' );
drawcoords( im_coords(:,im_ids), '', 0, 'g' );


% ids = smartSelection( im_coords, 3, 0 );

options = optimset( 'Display', 'off', ...
                    'Algorithm', {'levenberg-marquardt',0.00001}, ...
                   'MaxFunEvals', 100000, ...
                   'MaxIter', 1000000, ...
                   'TolFun',1e-19, ...
                   'ScaleProblem','Jacobian' );
               
actual_n = findNormalFromH( H );
actual_n = actual_n.a;

trng       = 0:1:30;
prng       = 0:1:45;
NUM_RES    = max(size(trng))*2*2*(max(size(prng)));
theta_0    = 30;
psi_0      = 0;
num        = 1;
angles     = cell (NUM_RES,1);
failReason = zeros(NUM_RES,1);
result     = zeros(NUM_RES,1);
planes     = zeros(NUM_RES,4);

for p=[-1,1],
    for i=trng,
        theta = theta_0 + i*p;
        for q=[-1,1],
            for j=prng,
                psi = psi_0 + j*q;
                x0 = [5, normalFromAngle( theta, psi, 'degrees' )' ];
                % Iterate
                [ x_iter, ~, exitflag, ~ ] = fsolve( @gp_iter_func, x0, options, im_coords(:,im_ids) );
                wc = find_real_world_points( im_coords, iter2plane(x_iter) );
                
                [mu_lwc,sd_wcl,lengths] = findLengthDist( wc, 0 );
                numbad = length(find(lengths > mu_lwc + 10*sd_wcl ));
                baddist = numbad > 1;
                    
                
                % checks
                f = notFit( im_coords, H, x_iter, 0.05 );
%                     f = var(lengths) < eps;
%                 lengths = speedDistFromCoords( wc );
                [vn, vd] = checkPlaneValidity( x_iter );
                if ~f && exitflag > 0 && vn && vd && ~baddist,
                    pass = 1;
                    failReason(num) = 0;
                else
                    if exitflag < 1,
                        failReason(num) = 1;
                    elseif ~vn,
                        failReason(num) = 2;
                    %elseif ~vd
                 %       failReason(num) = 3;
                    elseif baddist
                        failReason(num) = 4;
                    else
                        failReason(num) = 5;
                    end
                    pass = 0;
                end
                planes(num,:) = x_iter;
                result(num) = pass;
                angles{num} = [theta,psi];
                num = num + 1;
            end
            [theta,psi]
        end
    end
end
angarr = reshape([angles{:}],2,NUM_RES)';

draw_x0_NormalResults_script

saveas(gcf, strcat(fname,'.fig'));


save( strcat(fname, '.mat'), '*' );
