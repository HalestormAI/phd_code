function rx = mdrescal(x,flag,mx,stdx)
%MDRESCAL Rescales matrix with missing data as specified.
%  Rescales a matrix (x) with missing data indicated by
%  (flag) using means (mx) and standard deviations (stdx) 
%  specified.
%
%I/O:  rx = mdrescal(x,flag,mx,stdx);
%
%  If only three input arguments are supplied then the function
%  will not do variance rescaling, but only vector addition.
%
%I/O:  rx = mdrescal(x,flag,mx);
%
%See also: AUTO, MDAUTO, MDMNCN, MDSCALE, MNCN, SCALE, RESCALE

%Copyright Eigenvector Research, Inc. 1997-98
%By Barry M. Wise

[m,n] = size(x);
rx = ones(m,n)*flag;
if nargin == 4
  for i = 1:n
    z = find(x(:,i)~=flag);
    rx(z,i) = (x(z,i)*stdx(i))+mx(i);
  end
else
  for i = 1:n
    z = find(x(:,i)~=flag);
    rx(z,i) = (x(z,i)+mx(i));
  end
end
