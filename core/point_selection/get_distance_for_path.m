function [ total_distance, distances ]= get_distance_for_path( path, d_mat )

% Init Distance Vars
distances = zeros( 1,max(size(path))-1 );
total_distance = 0;

% Set current node to first path point
current_node = path(1);


 for i=2:max(size(path)),
    next_node = path(i);
    d = d_mat(current_node,next_node);
    
    distances(i-1) = d;
    
    current_node = next_node;
    total_distance = total_distance + d;
 end    