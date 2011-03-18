function [paths,distance_sums,distances] = pathfinder( num_points, num_rand, d_mat )

%combs = tic;
paths = combnk(1:num_points, num_rand);

%fprintf('Getting combinations takes %fseconds\n', toc(combs) );


paths(:,num_rand+1) = paths(:,1);

distance_sums = zeros(size(paths,1),1);
distances = zeros(size(paths,1), size(paths,2)-1);
% 
% pathsCell = num2cell(paths,2);
% 
% 
% cellTime = tic;
% matDistances = cellfun(@(pc)get_distance_for_path( pc, d_mat ), pathsCell );
% ct = toc(cellTime);
% fprintf('Getting distances using cells takes %fseconds\n', ct );
% 
% 
% pathTime = tic;
for i=1:size(paths,1),
    [ distance_sums(i), distances(i,:) ] = get_distance_for_path( paths(i,:), d_mat );  
end  
% pt = toc(pathTime);
% fprintf('Getting distances using loops takes %fseconds\n', pt );

% if distances ~= matDistances,
%     distances,matDistances,
%     error('Results are different :(');
% end
% 
% if ct > pt,
%     fprintf('\n\nCELLS TAKE LONGER\n');
% elseif ct < pt,
%     fprintf('\n\nLOOPS TAKE LONGER\n');
% else
%     fprintf('\n\nEQUAL TIMES\n');
% end