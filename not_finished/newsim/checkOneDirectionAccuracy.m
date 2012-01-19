% Measurements in metres...

FPS = 1;

%% Create plane and trajectories
% basePlane = [   -7.5        -7.5         7.5         7.5;
%                 -7.5         7.5         7.5        -7.5;
%                  -10         -10         -10         -10];
%            
% Horizontal
% baseTraj{1} = [(-7.5:FPS:7.5); zeros(1,round(15/FPS)+1); repmat(-10,1,round(15/FPS)+1)];
% 
% % Vertical
% baseTraj{2} = [zeros(1,round(15/FPS)+1); (-7.5:FPS:7.5); repmat(-10,1,round(15/FPS)+1)];
% 
% % Diagonal
% baseTraj{3} = [(-7.5:sqrt(FPS/2):7.5); (-7.5:sqrt(FPS/2):7.5); repmat(-10,1,round(15/sqrt(FPS/2))+1)];

%% Set up rotation, then create camera plane & Trajectories
THETA = 30;
PSI = 10;
GT_n = normalFromAngle(THETA,PSI,'degrees');
rotX = makehgtform('xrotate',deg2rad(THETA));
rotZ = makehgtform('zrotate',deg2rad(PSI));

rotation = rotZ(1:3,1:3)*rotX(1:3,1:3);

camPlane = rotation*basePlane;
camTraj = cellfun(@(x) rotation*x,baseTraj,'uniformoutput',false);

%% Convert to Image plane/trajectories

FOCAL = 0.25;

imPlane = wc2im(camPlane,-1/FOCAL);
imTraj = cellfun(@(x) wc2im(x,-1/FOCAL), camTraj,'uniformoutput',false);

imC = cellfun(@(x) traj2imc(x,FPS,1), imTraj,'uniformoutput',false);

%% Set up estimation parameters
if ~exist('grid','var')
    grid = generateNormalSet( (10.^(-4:-1)),1:2:20 );
end

fsolve_options;

output_iters = cell(length(baseTraj),1);
errored      = cell(length(baseTraj),1);
pass1        = cell(length(baseTraj),1);
pass2        = cell(length(baseTraj),1);
output_val   = cell(length(baseTraj),1);
est_n        = cell(length(baseTraj),1);
est_t        = cell(length(baseTraj),1);
est_p        = cell(length(baseTraj),1);
%% Estimate
for i=1:length(baseTraj)
    [~,output_iters{i},errored{i},pass1{i},pass2{i}] = gridEstimate( imC{i}, grid, 1:length(imC{i}), 0 );

    
    errors = cellfun( @(x) sum(gp_iter_func(x,imC{i}).^2), num2cell(output_iters{i},2));
    [~,MINIDX] = min(errors);
    output_val{i} =  output_iters{i}(MINIDX,:);
    
    est_n{i} = abc2n( output_val{i}(1:3) );

    [est_t{i},est_p{i}] = anglesFromN( est_n{i} );
end
fprintf('GT Theta: %d, GT Psi: %d, GT Focal: %.3f\n', THETA, PSI, -1/FOCAL);
disp('[ Horz_Theta     Horz_Psi ]')
disp('[ Vert_Theta     Vert_Psi ]:')
rad2deg([cell2mat(est_t);cell2mat(est_p)]')

disp('FOCALS (Horz, then Vert): ');
output_val{1}(4)
output_val{2}(4)
output_val{3}(4)