function outGrp = vectarrow(p0,p1,colorspec)
%Arrowline 3-D vector plot.
%   vectarrow(p0,p1) plots a line vector with arrow pointing from point p0
%   to point p1. The function can plot both 2D and 3D vector with arrow
%   depending on the dimension of the input
%
%   3rd argument is colourspec.
%
%   Example:
%       3D vector
%       p0 = [1 2 3];   % Coordinate of the first point p0
%       p1 = [4 5 6];   % Coordinate of the second point p1
%       vectarrow(p0,p1)
%
%       2D vector
%       p0 = [1 2];     % Coordinate of the first point p0
%       p1 = [4 5];     % Coordinate of the second point p1
%       vectarrow(p0,p1)
%
%   See also Vectline

%   Rentian Xiong 4-18-05
%   $Revision: 1.0

% IJH EDIT: Added colorspec and checking whether to hold or not.
if nargin < 3
    colorspec = 'b-';
end

shouldhold = strcmp(get(gca,'NextPlot'),'replace');

  if max(size(p0))==3
      if max(size(p1))==3
          x0 = p0(1);
          y0 = p0(2);
          z0 = p0(3);
          x1 = p1(1);
          y1 = p1(2);
          z1 = p1(3);
          lineHandle =  plot3([x0;x1],[y0;y1],[z0;z1],colorspec);   % Draw a line between p0 and p1
          
          p = p1-p0;
          alpha = 0.1;  % Size of arrow head relative to the length of the vector
          beta = 0.1;  % Width of the base of the arrow head relative to the length
          
          hu = [x1-alpha*(p(1)+beta*(p(2)+eps)); x1; x1-alpha*(p(1)-beta*(p(2)+eps))];
          hv = [y1-alpha*(p(2)-beta*(p(1)+eps)); y1; y1-alpha*(p(2)+beta*(p(1)+eps))];
          hw = [z1-alpha*p(3);z1;z1-alpha*p(3)];
          
          % BEGIN IJH EDIT TO FIX Z-AXIS ARROW HEAD
          scale = sqrt( sum((p0-p1).*(p0-p1)) );          
          if mean(hv(hv~= 0)) < eps
            hv = [y1-alpha*(p(2)-beta*(p(1)+scale)); y1; y1-alpha*(p(2)+beta*(p(1)+scale))];
          end
          if mean(hu(hu~= 0)) < eps
            hu = [x1-alpha*(p(1)+beta*(p(2)+scale)); x1; x1-alpha*(p(1)-beta*(p(2)+scale))];
          end
          % END EDIT
            
          
          hold on
          headHandle = plot3(hu(:),hv(:),hw(:),colorspec);  % Plot arrow head
          grid on
          xlabel('x')
          ylabel('y')
          zlabel('z')
          if shouldhold
            hold off
          end
      else
          error('p0 and p1 must have the same dimension')
      end
  elseif max(size(p0))==2
      if max(size(p1))==2
          x0 = p0(1);
          y0 = p0(2);
          x1 = p1(1);
          y1 = p1(2);
          lineHandle = plot([x0;x1],[y0;y1],colorspec);   % Draw a line between p0 and p1
          
          p = p1-p0;
          alpha = 0.1;  % Size of arrow head relative to the length of the vector
          beta = 0.1;  % Width of the base of the arrow head relative to the length
          
          hu = [x1-alpha*(p(1)+beta*(p(2)+eps)); x1; x1-alpha*(p(1)-beta*(p(2)+eps))];
          hv = [y1-alpha*(p(2)-beta*(p(1)+eps)); y1; y1-alpha*(p(2)+beta*(p(1)+eps))];
          
          hold on
          headHandle = plot(hu(:),hv(:),colorspec);  % Plot arrow head
          grid on
          xlabel('x')
          ylabel('y')
          if shouldhold
            hold off
          end
      else
          error('p0 and p1 must have the same dimension')
      end
  else
      error('this function only accepts 2D or 3D vector')
  end
  
  outGrp = hggroup;
  set(headHandle,'Parent',outGrp);
  set(lineHandle,'Parent',outGrp);

