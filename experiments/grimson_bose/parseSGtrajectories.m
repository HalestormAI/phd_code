function [traj,bbox_areas,frame, times] = parseSGtrajectories( object_hist, seq_path )

    max_label = max([object_hist(end).objects.label]);

    traj       = cell(max_label,1);
    times       = cell(max_label,1);
    bbox_areas = cell(max_label,1);
    
    textprogressbar('Generating Trajectories: ');
    for frameno = 1:length(object_hist)
        os = object_hist(frameno).objects;
        for o=1:length(os)
            lbl = os(o).label;
            bbox = [os(o).bbox_x;os(o).bbox_y];
            
            bbox_areas{lbl}(:,end+1) = diff(os(o).bbox_x)*diff(os(o).bbox_y);
%             traj{lbl}(:,end+1) = mean(bbox,2);
            traj{lbl}(:,end+1) = os(o).expected_y_t_plus_1_given_t(1:2);
            times{lbl}(:,end+1) = frameno;
        end
        textprogressbar(100*(frameno/length(object_hist)));
    end
    textprogressbar('\nAll done.');
    
    if nargin > 1
        files = dir([seq_path '/*.jpg']);
        files = sort({files.name});
        frame = imread([seq_path '/' files{1}]); 
    end
end
