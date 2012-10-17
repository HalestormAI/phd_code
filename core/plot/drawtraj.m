function f = drawtraj( traj, ttl, newfig, colour, lw, marker )
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
    
    if iscell(traj)
        cellfun(@(x) drawtraj(x,ttl,0,colour, lw, marker), traj);
        return
    end
    
    if(size(traj,1)==3)
        drawfun = @drawcoords3;
    else
        drawfun = @drawcoords;
    end
        
    
    f = drawfun(traj2imc(traj,1,1),ttl,0,colour, lw, marker);
end