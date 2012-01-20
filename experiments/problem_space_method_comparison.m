%% Set up dirs and filenames
ROOT_DIR = strcat('compare_problemspace_',datestr(now,'HH-MM-SS'));

mkdir( ROOT_DIR )
cd( ROOT_DIR );

fixed_nms = strcat('fixed_',['d,f';'t,d';'t,f';'t,p';'p,f';'p,d']);
method_nms = ['abc';'n_d'];

%% Experiment Parameters

ALPHAS = -10.^(-3:0.1:-1);
THETAS = 2:2:90;
PSIS   = -60:2:60;
DS = 1:1:20;

NUM_TRAJECTORIES = 1;
GT_T = 32;
GT_P = -16;
GT_D = 10;

GT_N = normalFromAngle( GT_T,GT_P );
GT_ALPHA = ALPHAS(10);


%% Generate Trajectories & Plane
basePlane = createPlane( GT_D, 0, 0, 1 );
baseTraj = addTrajectoriesToPlane( basePlane, [], NUM_TRAJECTORIES, 2000, 1, 0, 0, 15);

rotX = makehgtform('xrotate',-deg2rad(GT_T));
rotZ = makehgtform('zrotate',-deg2rad(GT_P));
rotation = rotZ*rotX;

camPlane = rotation(1:3,1:3)*basePlane;
camTraj = cellfun(@(x) rotation(1:3,1:3)*x,baseTraj,'uniformoutput',false);

imPlane = wc2im(camPlane,GT_ALPHA);
imTraj = cellfun(@(x) traj2imc(wc2im(x,GT_ALPHA),1,1), camTraj,'uniformoutput',false);

pF = drawPlane( imPlane );
cellfun( @(x) drawcoords(x,'',0,'k'),imTraj);
saveas(pF, 'trajectory.fig');

allfigs = figure;

%% Run scripts

for FIXED_VARS = 1:6
    f = figure;
    for METHOD = 1:2
        sp = subplot(1,2,METHOD);
        mthd_root = strcat('method_',method_nms(METHOD,:));
        mkdir(mthd_root);
        cd(mthd_root);

        if METHOD == 1
            X0_FUNC = @generateNormalSet;
            ERROR_FUNC = @traj_iter_func;
            GT_ITER = [n2abc(GT_N,GT_D)',GT_ALPHA];
            MARKER_COLOUR = 'ob';
        else
            X0_FUNC = @generateNormalSet_nd;
            ERROR_FUNC = @traj_iter_func_nd;
            GT_ITER = [GT_N',GT_D,GT_ALPHA];
            MARKER_COLOUR = 'or';
        end

        gridfn = strcat('fine_grid_',method_nms(METHOD,:),'.mat');
        if exist(gridfn,'file')
           load( gridfn, 'grid', 'gridVars');
        else
            [grid,gridVars] = X0_FUNC( ALPHAS,DS,THETAS,PSIS );
            save( gridfn, 'grid', 'gridVars')
        end
    
        
        
        expdir = fixed_nms(FIXED_VARS,:);
        examine_problem_space;
        
        title(strrep(sprintf('%s problem space for %s',method_nms(METHOD,:), fixed_nms(FIXED_VARS,:)),'_',' '));
        cd ../
    end
    
        sp = subplot(1,2,1);
        ax = axis;
        sp = subplot(1,2,2);
        axis(ax);   
    saveas(f,sprintf('fixed_%s_problemspace_comparison.fig',fixed_nms(FIXED_VARS,:)));
    close all;
end
save expdata.mat
saveas(allfigs,'all_errors_comparison.fig');

% pf = figure;
% ff  = zeros(12,1);
% fAx = zeros(12,1);
% for METHOD = 1:2
%     for fx = 1:6
%         plot_id = fx+(6*(METHOD-1));
%         sp = subplot(2,6,plot_id);
%         filename = sprintf('method_%s/%s/error_plot.fig', ...
%                         method_nms(METHOD,:), fixed_nms(fx,:)...
%                    );
%         ff(plot_id) = openfig(filename, 'new','invisible');
%         fAx(plot_id) = get(ff(plot_id),'child');
%         copyobj(get(fAx(plot_id),'child'),sp);
%         xlabel(get(get(fAx(plot_id),'XLabel'),'String'));
%         ylabel(get(get(fAx(plot_id),'YLabel'),'String'));
%         zlabel(get(get(fAx(plot_id),'ZLabel'),'String'));
%         grid on;
%         view(-126,18);
%         clear fAx ff;
%     end
% end
