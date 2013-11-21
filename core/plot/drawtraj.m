function [f,g] = drawtraj( traj, ttl, newfig, colour, lw, marker, returnline )
% Input:
%   traj        Trajectory Set
%   ttl         Figure title
%   newfig      Boolean - create a new figure or not?
%   colour      Line colour
%   lw          Line width
%   marker      Line Marker
    if nargin < 2
        ttl = '';
    end
    if nargin < 3
        newfig = 1;
    end
    if nargin < 4
        colour = 'k';
    end
    if nargin < 5 || isempty(lw),
        lw = 1;
    end
    if nargin < 6,
        marker = '-';
    end

    if newfig > 0,
        f = figure;
        title(ttl);
    else 
        f = gcf;
    end
    hold on;
    
    if iscell(traj)
        [~,line_handles] = cellfun(@(x) drawtraj(x,ttl,0,colour, lw, marker,1), traj);
        
        g = hggroup;
        set(line_handles, 'Parent', g )
        return
    end
    
    if(size(traj,1)==3)
%         drawfun = @drawcoords3;
        g = plot3(traj(1,:),traj(2,:),traj(3,:),sprintf('%s', marker), 'Color', colour, 'LineWidth',lw, 'MarkerSize', 10 );
    else
%         drawfun = @drawcoords;
        g = plot(traj(1,:),traj(2,:),sprintf('%s', marker), 'Color', colour, 'LineWidth',lw, 'MarkerSize', 10 );
    end
     
%     [f,g] = drawfun(traj2imc(traj,1,1),ttl,0,colour, lw, marker);
    
    if nargin >= 7 && returnline
        f = g;
    end
end