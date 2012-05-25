%{
% Set up constants for iterator
NOFIG = 1;
NOSAVE = 1;
DATAIN = 0;

D = 10;
FOC = 1;

GT_theta = 13;
GT_psi = -37;

params = [GT_theta, GT_psi];
constants = [D,FOC];

stddev = 0.1;
stddev_w = 0;

plane_details = createPlaneDetails( params, constants, [stddev,stddev_w] );

% Focal Length Range
FOCAL_LENGTHS = [FOC];[10.^(-2:0.5:2)];
%}
gradients = ones(length(FOCAL_LENGTHS),1);

completeErrors = cell(length(FOCAL_LENGTHS),1);
bestPick = zeros(length(FOCAL_LENGTHS),2);
minErrors = zeros(length(FOCAL_LENGTHS),1);
bestAngles = cell(length(FOCAL_LENGTHS),1);

for f=1:length(FOCAL_LENGTHS)
%    try
        [ssd_errors,best_pick(f,:),minErrors(f),bestAngles{f}] = iterator_parfor( [D,FOCAL_LENGTHS(f)], plane_details );
        theta_varies = (mean(ssd_errors,2));
        [max_error, max_id] = max(theta_varies);
        [min_error, min_id] = min(theta_varies);
        gradients(f) = (max_error - min_error) /  ( max_id - min_id);
        completeErrors{f} = ssd_errors;

        
%{        
    catch err
        disp(err)
        errCount = errCount + 1;
        if errCount == f && f > 1
            disp('TOO MANY ERRORS');
            errCount,f
            rethrow(error);
        end
    end
%}
end
return;
angleErrors = cellfun( @(x) angleError( normalFromAngle(x(1),x(2)), normalFromAngle(GT_theta,GT_psi) ), bestAngles );
figure;
scatter3(log10(FOCAL_LENGTHS),minErrors,angleErrors, '*');
hold on;
scatter3(log10(FOC),minErrors(FOCAL_LENGTHS==FOC),angleErrors(FOCAL_LENGTHS==FOC),'or');
xlabel('log_{10}(f)');
ylabel('Minimum function error, min(E_f)');
zlabel('Angular Error for min(E_f)');
