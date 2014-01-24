function sx = mdscale(x,flag,mx,stdx)
%MDSCALE Scales matrix with missing data as specified.
%  Scales a matrix (x) with missing data indicated by
%  (flag) using means (mx) and standard deviations (stds) 
%  specified.
%
%I/O:  sx = mdscale(x,flag,mx,stdx);
%
%  If only three input arguments are supplied then the function
%  will not do variance scaling, but only vector subtraction.
%
%I/O:  sx = mdscale(x,flag,mx);
%
%See also: AUTO, MDAUTO, MDMNCN, MDRESCAL, MNCN, SCALE, RESCALE

%Copyright Eigenvector Research, Inc. 1997-98
%By Barry M. Wise

[m,n] = size(x);
sx = ones(m,n)*flag;
if nargin == 4
  for i = 1:n
    z = find(x(:,i)~=flag);
    sx(z,i) = (x(z,i)-mx(i))./stdx(i);
  end
else
  for i = 1:n
    z = find(x(:,i)~=flag);
    sx(z,i) = (x(z,i)-mx(i));
  end
end
