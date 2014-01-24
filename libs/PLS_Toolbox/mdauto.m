function [ax,mx,stdx] = mdauto(x,flag)
%MDAUTO Autoscales matrix with missing data to mean zero unit variance.
%  Autoscales matrix (x) with missing values indicated
%  by (flag), returning a matrix with columns with zero mean and
%  unit variance columns (ax), the vectors of means (mx), and
%  standard deviations (stdx) used in the scaling.
%
%I/O: [ax,mx,stdx] = mdauto(x,flag);
%
%See also:  AUTO, MDMNCN, MDRESCAL, MDSCALE, MNCN, SCALE, RESCALE

%Copyright Eigenvector Research, Inc. 1997-98
%By Barry M. Wise

[m,n] = size(x);
mx = zeros(1,n);
stdx = zeros(1,n);
ax = ones(m,n)*flag;
for i = 1:n
  z = find(x(:,i)~=flag);
  mx(i) = mean(x(z,i));
  stdx(i) = std(x(z,i));
  ax(z,i) = (x(z,i)-mx(i))/stdx(i);
end
