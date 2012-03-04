
if ~exist('trajData','var')
    filename = input('Filename: ','s');
    fid = fopen(filename);
    trajData = textscan( fid, '%d\t%f\t%f' );
    fclose(fid);
end

trajIDs = unique( trajData{1} );

trajectories = cell( length(trajIDs), 1 );

for i=1:length(trajIDs)
    trajectories{i} = [];
end

for i=1:length( trajData{1} )
        coord = [trajData{2}(i);trajData{3}(i)];    
        trajectories{trajData{1}(i)+1}(:,end+1) = coord;
end

imTraj = cellfun(@(x) traj2imc(x,1,1), trajectories,'uniformoutput',false);

imTraj(find(cellfun(@isempty,imTraj))) = [];