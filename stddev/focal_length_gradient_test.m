% Set up constants for iterator
NOFIG = 1;
NOSAVE = 1;
DATAIN = 0;

% Focal Length Range
FOCAL_LENGTHS = [10.^(-4:4)];

TRUE_F = 1;

D = 10;

gradients = ones(length(FOCAL_LENGTHS),1);

completeErrors = cell(length(FOCAL_LENGTHS),1);

parfor f=1:length(FOCAL_LENGTHS)
%    try
        exp_constants = [D,FOCAL_LENGTHS(f)];
        [ssd_errors, plane_details] = iteratorFunc( exp_constants );
        theta_varies = (mean(ssd_errors,2));
        [max_error, max_id] = max(theta_varies);
        [min_error, min_id] = min(theta_varies);
        gradients(f) = (max_error - min_error) /  ( max_id - min_id);
        completeErrors{f} = ssd_errors;
        clear exp_constants;
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

figure;
scatter(log10(FOCAL_LENGTHS),gradients, '*');
