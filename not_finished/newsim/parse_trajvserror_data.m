fixAngle = @(x) pi/2 - abs(pi/2 - x);

for p = 1:size(RESULT,1)
    
    theta = PLANE_PARAMS(1,p);
    psi   = PLANE_PARAMS(2,p);
    d     = PLANE_PARAMS(3,p);
    
    N = normalFromAngle( theta, psi );
    
    for i = 1:size(RESULT,2)
        if ~isempty( RESULT{p,i} )
            
            [Ne,De] = abc2n(RESULT{p,i}(1:3)');
            [Te,Pe] = anglesFromN( Ne );
            
            GLOBAL_ANGLE_ERROR(p,i) = fixAngle(deg2rad(angleError( N, Ne )));
            AOE_ERROR(p,i) = fixAngle(deg2rad(theta) - real(Te));
            YAW_ERROR(p,i) = fixAngle(deg2rad(psi) - real(Pe));
            [d, De]
            D_ERROR(p,i)   = (d - De);
            FOC_ERROR(p,i) = (1/FOCAL - RESULT{p,i}(4));
            
            FOCAL_LENGTHS(p,i) = RESULT{p,i}(4);
        else
            GLOBAL_ANGLE_ERROR(p,i) = NaN;
            AOE_ERROR(p,i) = NaN;
            YAW_ERROR(p,i) = NaN;
            D_ERROR(p,i)   = NaN;
            FOC_ERROR(p,i) = NaN;
            
        end
    end
end

%% Get means
for i = 1:size(RESULT,2)
    mean_GlobalError = nanmean(GLOBAL_ANGLE_ERROR);
    mean_AOE_ERROR    = nanmean(AOE_ERROR);
    mean_YAW_ERROR    = nanmean(YAW_ERROR);
    mean_D_ERROR      = nanmean(D_ERROR  );
    mean_FOC_ERROR    = nanmedian(FOC_ERROR);
end

OVERCONSTRAINEDNESS = abs([UNKNOWNS-mean(cell2mat(NUM_EQNS'),2)]);

%% Plot Figures
figure;
subplot(3,2,1);
plot(1:length(OVERCONSTRAINEDNESS),OVERCONSTRAINEDNESS)
title('Number of Trajectories vs Number of Overconstraining Equations');
xlabel('No. Trajectories');
ylabel('No. Overconstraining Eqns');

subplot(3,2,2);
plot(1:length(OVERCONSTRAINEDNESS),mean_GlobalError)
title('Number of Trajectories vs Mean Normal Angle Error');
xlabel('No. Trajectories');
ylabel('Mean Normal Angle Error (radians)');
axis([ 1 length(OVERCONSTRAINEDNESS) -pi/2 pi/2])
subplot(3,2,3);
plot(1:length(OVERCONSTRAINEDNESS),mean_AOE_ERROR)
title('Number of Trajectories vs Mean AOE Error');
xlabel('No. Trajectories');
ylabel('Mean AOE Error (radians)');
axis([ 1 length(OVERCONSTRAINEDNESS) -pi/2 pi/2])

subplot(3,2,4);
plot(1:length(OVERCONSTRAINEDNESS),mean_YAW_ERROR)
title('Number of Trajectories vs Mean Yaw Error');
xlabel('No. Trajectories');
ylabel('Mean Yaw Error (radians)');
axis([ 1 length(OVERCONSTRAINEDNESS) -pi/2 pi/2])

subplot(3,2,5);
plot(1:length(OVERCONSTRAINEDNESS),mean_D_ERROR)
title('Number of Trajectories vs Mean Depth Error');
xlabel('No. Trajectories');
ylabel('Mean D Error (mm)');

subplot(3,2,6);
plot(1:length(OVERCONSTRAINEDNESS),mean_FOC_ERROR);
title('Number of Trajectories vs Median Focal Length Error');
xlabel('No. Trajectories');
ylabel('Median Length Error (mm)');