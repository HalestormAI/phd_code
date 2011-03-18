clear;
close all;

NOISE2=0.40;T=10;P=16;D=3;DELTA=0.05;


if ~exist('T','var'),
    T = input('Input Theta: ');
end
if ~exist('P','var'),
    P = input('Input Psi: ');
end
if ~exist('D','var'),
    D = input('Input D: ');
end
if ~exist('NOISE2','var'),
    NOISE2 = input('Input Type-2 Noise: ');
end
if ~exist('DELTA','var'),
    DELTA = input('Input Selection DELTA: ');
end




% Make simulated data
[actual_n,~,~,coords,im_coords] = make_test_data(T, 7, 1,P, 1000, NOISE2 );
actual_n

% Find same length vectors and select 3.
[ids_full,usable,im_ids] = pickIds( coords, im_coords, DELTA );

% ids = smartSelection( im_coords, 3, 0 );

options = optimset( 'Display', 'off', ...
                    'Algorithm', {'levenberg-marquardt',0.00001}, ...
                   'MaxFunEvals', 100000, ...
                   'MaxIter', 1000000, ...
                   'TolFun',1e-19, ...
                   'ScaleProblem','Jacobian' );
               


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
                x0 = [7, normalFromAngle( theta, psi, 'degrees' )' ];
                % Iterate
                [ x_iter, ~, exitflag, ~ ] = fsolve( @gp_iter_func, x0, options, im_coords(:,im_ids) );
                wc = find_real_world_points( im_coords, iter2plane(x_iter) );
                
                [mu_lwc,sd_wcl,lengths] = findLengthDist( wc, 0 );
                numbad = length(find(lengths > mu_lwc + 10*sd_wcl ));
                baddist = numbad > 1;
                    
                
                % checks
                f = notFit( im_coords, [7,actual_n'], x_iter, 0.05 );
%                     f = var(lengths) < eps;
%                 lengths = speedDistFromCoords( wc );
                [vn, vd] = checkPlaneValidity( x_iter );
                if ~f && exitflag > 0 && vn && vd,
                    pass = 1;
                    failReason(num) = 0;
                else
                    if exitflag < 1,
                        failReason(num) = 1;
                    elseif ~vn,
                        failReason(num) = 2;
                    elseif ~vd
                        failReason(num) = 3;
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


fname = sprintf('%s/x0_converge_T2_noise=%.2f_T=%d_P=%d_D=%d_DELTA=%.3f', getTodaysFolder(), NOISE2, T, P, D,DELTA )
saveas(gcf, strcat(fname,'.fig'));
save( strcat(fname, '.mat'), '*' );
