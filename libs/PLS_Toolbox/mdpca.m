function [scores,loads,estdata] = mdpca(data,pcs,flag,tol)
%MDPCA Principal Components for matrices with missing data.
%  The inputs are the input matrix (data), the number of 
%  principal components assumed to be significant (pcs), the
%  value of the flag used for missing data (flag), e.g. set 
%  flag = 9999 and put 9999 for each missing value, and an
%  optional variable that sets the convergence tolerance (tol).
%  If tol is not specified it is set to 1e-5. The outputs are
%  the estimated principal components scores (scores),
%  loadings (loads) and an estimate of the data matrix with
%  the missing values filled in (estdata). 
%
%  This function works by calculating a PCA model and then 
%  replacing the missing data with values that are most 
%  consistant with the model. A new PCA model is then 
%  calculated, and the process is repeated until the estimates 
%  of the missing data converge. This is one of many ways to
%  treat the missing data problem.
%
%  I/O format: [scores,loads,estdata] = mdpca(data,pcs,flag,tol);
%
%  See also: PCA, MISSDAT, MDDEMO

%  Copyright Eigenvector Research, Inc. 1992-98
%  Modified 5/94 BMW

if nargin < 4
  tol = 1e-5;
end
[m,n]    = size(data);
mdlocs   = zeros(m,n);
locs     = find(data==flag);
mdlocs(locs) = ones(size(flag));
data(locs)   = zeros(size(flag));

totssq = sum(sum(data.^2));
change = 1;
count  = 0;
while change > tol
  count = count + 1;
  s = sprintf('Now working on iteration number %g',count);
  disp(s)
  if n < m
    cov = (data'*data)/(m-1);
    [u,s,v] = svd(cov);
  else
    cov = (data*data')/(m-1);
    [u,s,v] = svd(cov);
    v = data'*v;
    for i = 1:m
      v(:,i) = v(:,i)/norm(v(:,i));
    end
  end
  loads = v(:,1:pcs);
  scores = data*loads;
  estdata = data;
  for i = 1:m
    vars = find(mdlocs(i,:));
    if isempty(vars) == 0
      rm = replace(loads,vars);
      estdata(i,:) = data(i,:)*rm;
    end
  end
  dif = data - estdata;
  change = sum(sum(dif.^2));
  s = sprintf('Sum of squared differences in missing data estimates = %g',change);
  disp(s)
  data = estdata;
  if count == 50
    disp('Algorithm failed to converge after 50 iterations')
    change = 0;
  end
end
disp('  ')
disp('Now forming final PCA model')
disp('   ')
ssq = [[1:pcs]' zeros(pcs,2)];
for i = 1:pcs
  resmat = data - scores(:,1:i)*loads(:,1:i)';
  resmat = resmat - resmat.*mdlocs;
  ssqres = sum(sum(resmat.^2));
  ssq(i,3) = (1 - ssqres/totssq)*100;
end
ssq(1,2) = ssq(1,3);
for i = 2:pcs
  ssq(i,2) = ssq(i,3) - ssq(i-1,3);
end
disp('    Percent Variance Captured') 
disp('           by PCA Model')
disp('     Based on Known Data Only')
disp('  ')
disp('    PC#      %Var      %TotVar')
disp(ssq)
