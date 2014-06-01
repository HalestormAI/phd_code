function [trajectories, traj_times] = trajectories_from_cvml( filename )
% Takes ground-truth bounding-box trajectories from a CSV file and turns
% them into centroid-based trajectories we can use in this system.
%
% This assumes the data has been converted from CVML format to a CSV using
% the guide here: 
% http://dragonwood-blastevil.blogspot.co.uk/2012/10/read-cvml-into-matlab.html
%
% Namely:  $ xsltproc cvml_csv.xslt myfile.xml > myfile.csv

    % load data (post conversion to CSV)
    raw_data = dlmread(filename);
    
    % Get tracker ids
    tracker_ids = unique(raw_data(:,2));
    
    
    time_indices =  ones(length(tracker_ids),1);
    num_pts      = zeros(length(tracker_ids),1);
    trajectories =  cell(length(tracker_ids),1);
    traj_times   =  cell(length(tracker_ids),1);
    
    % Pre-allocate trajectory arrays inside cells
    for t=1:length(tracker_ids)
        num_pts(t) = nnz(raw_data(:,2) == tracker_ids(t));
        trajectories{tracker_ids(t)} = zeros(2,num_pts(t));
    end
   
    %
    for r=1:length(raw_data)
        row = raw_data(r,:);
        
        frame_no  = row(1);
        object_id = row(2);
        xpos      = row(3) + 0.5*row(5);
        ypos      = row(4) + 0.5*row(6);
        
        % store position and frame number
        trajectories{object_id}(:,time_indices(object_id)) = [xpos;ypos];
        traj_times{object_id}(:,time_indices(object_id)) = frame_no;
        
        time_indices(object_id) = time_indices(object_id)+1;
    end
    
    

end