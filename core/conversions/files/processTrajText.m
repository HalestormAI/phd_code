function [trajectories,frame] = processTrajText( filename )


    if nargin < 1
        filename = input('Filename: ','s');
    end
    fid = fopen(filename);
    trajData = textscan( fid, '%d\t%f\t%f' );
    fclose(fid);

    trajIDs = unique( trajData{1} );

    raw_trajectories = cell( length(trajIDs), 1 );

    for i=1:length(trajIDs)
        raw_trajectories{i} = [];
    end

    for i=1:length( trajData{1} )
        trajectory_id = trajData{1}(i)+1;
        coord = [trajData{2}(i);trajData{3}(i)];    
        raw_trajectories{trajectory_id}(:,end+1) = coord;
    end

%     trajectories = cellfun(@(x) traj2imc(x,1,1), raw_trajectories,'uniformoutput',false);
    trajectories = raw_trajectories;
    trajectories(cellfun(@isempty,trajectories)) = [];

    % Now load in the image frame
    path = fileparts(filename);
    dirname = path;

    if exist([dirname,'/frame.jpg'],'file')
        frame = imread([dirname,'/frame.jpg']);
    else
        warning('ijh:trajectory_loader:noframe','No frame image file was found. Frame will have to be manually imported.');
        frame = 0;
    end
end