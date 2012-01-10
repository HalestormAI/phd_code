NUM_ATTEMPTS = 250;

drnvars = 0:0.25:5;
basePlane = [   -7.5        -7.5         7.5         7.5;
-7.5         7.5         7.5        -7.5;
-10         -10         -10         -10];
startPoint{1} = [-7.5;0;-10];
startPoint{2} = [4;-7.5;-10];
startPoint{3} = [6;5;-10];
startDrn{1} = 0;startDrn{2} = 90;startDrn{3} = 210;

drnOutput = cell(length(drnvars),NUM_ATTEMPTS);
baseTrajs = cell(length(drnvars),NUM_ATTEMPTS);
for drnVarId = 1:length(drnvars)
    for attemptId = 1:NUM_ATTEMPTS
        [baseTraj] = addTrajectoriesToPlane( basePlane, [], 20, 100, 1, 0, [], drnvars(drnVarId),startPoint,startDrn );
        checkOneDirectionAccuracy;
        baseTrajs{drnVarId,attemptId} = baseTraj;
        drnOutput{drnVarId,attemptId} = output_val;
    end
end
return

drnOutput2 = drnOutput';

expOutputs = cell( length(drnvars), 1 );
minOutput = zeros( length(drnvars), 4 );
for i=1:length(drnvars)
    expOutputs{i} = vertcat(drnOutput2{:,i});
    
    minOutput(i,:) = findMinimumVector( expOutputs{i} );
end

GT_n = normalFromAngle(THETA,PSI);

% output_res = horzcat(drnOutput{:})';
% output_ns = cellfun(@abc2n, output_res,'uniformoutput',false); 

ax = [-1 1 -1 1 -1 0];
labels = ['N_x';'N_y';'N_z'];
for i=1:size(output_ns,2)
    these_ns = vertcat(output_ns{:,i});
    figure;
    scatter3( these_ns(:,1),these_ns(:,2),these_ns(:,3),24,drnvars,'*');
    plotCross( GT_n, reshape(ax, 2,3)', '-m', labels );
    axis(ax);
    title(sprintf('Estimated N for motion %d', i));
end