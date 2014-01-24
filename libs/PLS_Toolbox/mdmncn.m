function [mcx,mx] = mdmncn(x,flag)
%MDMNCN Mean centers matrix with missing data to mean zero.
%  Mean centers matrix (x) with missing values indicated
%  by (flag), returning a matrix with mean zero columns (mcx) 
%  and the vector of means (mx) used in the scaling.
%
%I/O: [mcx,mx] = mdmncn(x,flag);
%
%See also:  AUTO, MDAUTO, MDRESCAL, MDSCALE, MNCN, SCALE, RESCALE

%Copyright Eigenvector Research 1997-98
%By Barry M. Wise

[m,n] = size(x);
mx = zeros(1,n);
mcx = ones(m,n)*flag;
for i = 1:n
  z = find(x(:,i)~=flag);
  mx(i) = mean(x(z,i));
  mcx(z,i) = x(z,i)-mx(i);
end
