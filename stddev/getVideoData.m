function [trajectories, times, lengths,frame] = getVideoData( path )
makeCpp('tracker_2/Tracker.cpp');
    if exist( path,'file' ) == 2 % Path is a file
        vid = VideoReader(path);
        frame = read(vid,1);
    elseif exist( path, 'file' ) == 7 % Path is a directory
        l = dir(strcat(path,'/*.jpg'));
        frame = imread(strcat(path,'/',l(1).name));
    end
    [trajectories,times] = Tracker( path );
    lengths = cellfun(@length,times);
end