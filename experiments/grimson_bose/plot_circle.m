function plot_circle(x,y,r,nsides,linespec,varargin)
    %x and y are the coordinates of the center of the circle
    %r is the radius of the circle
    %0.01 is the angle step, bigger values will draw the circle faster but
    %you might notice imperfections (not very smooth)
    
    if nargin < 4 || isempty(nsides)
        nsides = 360;
    end
    
    inc = 2*pi/nsides;
    ang=0:inc:2*pi; 
    xp=r*cos(ang);
    yp=r*sin(ang);
    if nargin < 5 || isempty(linespec)
        p = plot(x+xp,y+yp);
    else
        p = plot(x+xp,y+yp, linespec);
    end
    
    if ~isempty(varargin) 
        for v=1:2:length(varargin)
            set(p,varargin{v}, varargin{v+1});
        end
    end
end