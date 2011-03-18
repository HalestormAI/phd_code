function [ start_points, end_points ] = get_lines_on_plane( a,b,c,d,k,st,nd )
%GET_LINES_ON_PLANE Find a set of discrete points on a plane, then find all
%   lines of distance k from eachother.

start_points = zeros(3,4);
end_points = zeros(3,4);

for cnt=1:4,
    x = rand(1) * (nd-st) + st;
    y = rand(1) * (nd-st) + st;
    z = (-d - a*x - b*y) / c;
    
    start_points(:,cnt) = [x;y;z];
end

for cnt=1:4,
    % Make sure x and y aren't the same as in the original
    for i=1:Inf,
        x = rand(1) * (nd-st) + st;
        y = rand(1) * (nd-st) + st;
        lhs = k^2 - ( start_points(1,cnt) - x )^2 - ( start_points(2,cnt) - y )^2;
        
        if x ~= start_points(1,cnt) && y ~= start_points(2,cnt) && lhs >=0,
            break;
        end
    end
    
    z = sqrt(lhs) + start_points(3,cnt);
    
    end_points(:,cnt) = [x;y;z];
end


start_points
end_points