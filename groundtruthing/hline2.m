% HLINE - Plot 2D lines defined in homogeneous coordinates.
%
% Function for ploting 2D homogeneous lines defined by 2 points
% or a line defined by a single homogeneous vector
%
% Usage:   hline(p1,p2)   where p1 and p2 are 2D homogeneous points.
%          hline(p1,p2,'colour_name')  'black' 'red' 'white' etc
%          hline(l)       where l is a line in homogeneous coordinates
%          hline(l,'colour_name')
%

%  Peter Kovesi
%  School of Computer Science & Software Engineering
%  The University of Western Australia
%  pk @ csse uwa edu au
%  http://www.csse.uwa.edu.au/~pk
%
%  April 2000

function hline2(a,b,c)

col = 'blue';  % default colour
style = '-';
if nargin >= 2 & isa(a,'double')  & isa(b,'double')   % Two points specified
    
    p1 = a./a(3);        % make sure homogeneous points lie in z=1 plane
    p2 = b./b(3);
    
    if nargin == 3 & isa(c,'char')  % 2 points and a colour specified
        col = c;
    end
    
elseif nargin >= 1 & isa(a,'double')       % A single line specified
    
    a = a./a(3);   % ensure line in z = 1 plane (not needed??)
    
    xlim = get(get(gcf,'CurrentAxes'),'Xlim');
    ylim = get(get(gcf,'CurrentAxes'),'Ylim');
    
    if abs(a(1)) > abs(a(2))
        % line is more vertical
        l_xneg = hcross([xlim(1) ylim(1) 1], [xlim(2) ylim(1) 1]);
        l_xpos = hcross([xlim(1) ylim(2) 1], [xlim(2) ylim(2) 1]);
        
        p1 = hcross(a, l_xneg);
        p2 = hcross(a, l_xpos);
    else
        % line more horizontal
        l_yneg = hcross([xlim(1) ylim(1) 1], [xlim(1) ylim(2) 1]);
        l_ypos = hcross([xlim(2) ylim(1) 1], [xlim(2) ylim(2) 1]);
        
        p1 = hcross(a, l_yneg);
        p2 = hcross(a, l_ypos);
    end
    
    if nargin >= 2 & isa(b,'char') % 1 line vector and a colour specified
        col = b;
    end
    if nargin == 3 & isa(c,'char') % 1 line vector and a colour specified
        style = c;
    end
    
else
    error('Bad arguments passed to hline');
end

line([p1(1) p2(1)], [p1(2) p2(2)], 'color', col,'LineStyle',style);