% CDIR=cd;
% addpath( CDIR ); 
% 
% setup_exp;
% 
% ALPHAS   = -10.^(-3:0.1:-1);
% THETAS   = 1:10:90;
% PSIS     = -60:10:60;
% DS       = 1:5:30;
% 
% NUM_TRAJECTORIES = 10;
% 
% if exist('param_file','var')
%     load(param_file,'PLANE_PARAMS');
%     NUM_PLANES = size(PLANE_PARAMS,2);
% else
%     NUM_PLANES = 100;
%     PLANE_PARAMS = [ randi(89,1,NUM_PLANES)       ;
%                      randi(120,1,NUM_PLANES) - 60 ; 
%                      rand(1,NUM_PLANES) * 18 + 10 ;
%                     -randi(10,1,NUM_PLANES).*0.001];
%     save plane_params.mat PLANE_PARAMS;
% end
% 
% 
% 
% if matlabpool('size') == 0
%     matlabpool open 3;
% end
% 
% gridfn = 'fine_grid.mat';
% if exist(gridfn,'file')
%    load( gridfn, 'x0grid', 'gridVars');
% else
%     [x0grid,gridVars] = generateNormalSet( ALPHAS,DS,THETAS,PSIS );
%     save( gridfn, 'x0grid', 'gridVars')
% end
% 
% fsolve_options
% 
% all_x_iters      =  cell(NUM_PLANES, 1);
% all_fval         =  cell(NUM_PLANES, 1);
% all_exitflag     =  cell(NUM_PLANES, 1);
% all_output       =  cell(NUM_PLANES, 1);
% all_timeToSolve  =  cell(NUM_PLANES, 1);
% all_baseTraj     =  cell(NUM_PLANES, 1);
% all_camTraj      =  cell(NUM_PLANES, 1);
% all_imTraj       =  cell(NUM_PLANES, 1);
% all_bestiter     =  cell(NUM_PLANES, 1);
% all_bestangleerr = zeros(NUM_PLANES, 1);
% all_basePlane    =  cell(NUM_PLANES, 1);
% all_camPlane     =  cell(NUM_PLANES,1 );
% all_imPlane      =  cell(NUM_PLANES, 1);
% all_usedCoords   =  cell(NUM_PLANES, 1);
% 
% for pId = 1:length(PLANE_PARAMS)
%     fprintf('Estimating Plane %d of %d\n\t', pId, NUM_PLANES);
% 
%     %% Experiment Parameters
%     GT_T        = PLANE_PARAMS(1,pId);
%     GT_P        = PLANE_PARAMS(2,pId);
%     GT_D        = PLANE_PARAMS(3,pId);
%     GT_ALPHA    = PLANE_PARAMS(4,pId);
% 
%     GT_N        = normalFromAngle( GT_T,GT_P );
%     GT_ITER     = [n2abc(GT_N,GT_D)',GT_ALPHA];
% 
%     rotX        = makehgtform('xrotate',-deg2rad(GT_T));
%     rotZ        = makehgtform('zrotate',-deg2rad(GT_P));
%     rotation    = rotZ*rotX;
%     
%     basePlane   = createPlane( GT_D, 0, 0, 1 );
%     camPlane    = rotation(1:3,1:3)*basePlane;
%     imPlane     = wc2im(camPlane,GT_ALPHA);
%     
%     baseTraj    = addTrajectoriesToPlane( basePlane, [], NUM_TRAJECTORIES, 2000, 1, 1, .2, 10, 1, 0.01);
%     camTraj     = cellfun(@(x) rotation(1:3,1:3)*x,baseTraj,'uniformoutput',false);
%     imTraj      = cellfun(@(x) traj2imc(wc2im(x,GT_ALPHA),1,1), camTraj,'uniformoutput',false);
% 
%     im_coords   = horzcat(imTraj{:});
%     ids_full    = maxPaths( im_coords, 6,0.01,0);
%     all_usedCoords{pId} = im_coords( :, ids_full );
%     
%     
%     all_basePlane{pId} = basePlane;
%     all_camPlane{pId} = camPlane;
%     all_imPlane{pId} = imPlane;
%     all_baseTraj{pId}  = baseTraj;
%     all_camTraj{pId}   = camTraj;
%     all_imTraj{pId}    = imTraj;
% 
%     angleErrors = zeros(size(x0grid,1),1);
%     x_iter      =  cell(size(x0grid,1),1);
%     fval        =  cell(size(x0grid,1),1);
%     exitflag    = zeros(size(x0grid,1),1);    
%     
%     parfor b=1:length(x0grid)
%         [ x_iter{b}, fval{b}, exitflag(b)] = fsolve(@(x) gp_iter_func(x, all_usedCoords{pId}),x0grid(b,:),options);
%         angleErrors(b) = angleError( GT_N, abc2n(x_iter{b}(1:3)),1,'radians' );
%     end
%     
%     
%     all_fval{pId}        = cellfun(@(x) sum(x.^2),fval);
% 
%     [minfval,MINIDX] = min(all_fval{pId});
% 
%     fprintf('\t  Minimum fval: %4.6f\n', minfval);
% 
%     all_bestiter{pId}     = x_iter{MINIDX}; 
%     all_bestangleerr(pId) = angleErrors(MINIDX);
%     fprintf('\t  Minimum angle err: %1.4f radians (%3.2f)\n',all_bestangleerr(pId),rad2deg(all_bestangleerr(pId)));
% 
%     all_x_iters{pId}     = x_iter;
%     all_exitflag{pId}    = exitflag;
%     
% end


f = figure;
subplot(1,2,1)
scatter(1:NUM_PLANES, all_bestangleerr, 24,'*b');
xlabel('Plane ID');
ylabel('Angle Error Between Est and GT Plane Normals (radians)');
subplot(1,2,2)
scatter(1:NUM_PLANES, cellfun(@min,all_fval), 24,'*b');
saveas(f, 'error_results.fig');
xlabel('Plane ID');
ylabel('Function evaluation error at the end of optimisation');

save allexp_data;

clear expdir;

cd ../
rmpath(CDIR);