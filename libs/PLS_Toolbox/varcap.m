function vc = varcap(x,loads,scl);
%VARCAP Variance captured for each variable in PCA model
%  Calculates and displays the percent variance captured 
%  for each variable and number of PCs in a PCA model. The
%  inputs are the properly scaled data (x) with associated
%  loadings matrix (loads). An optional input (scl) specifies
%  the x-axis for plotting. The output is the matrix of 
%  variance captured (vc) for each variable for each number
%  of PCs considered (vc is number of PCs by number of variables).
%
%I/O: vc = varcap(x,loads,scl);
%
%See also: PCA, PCAGUI

%Copyright Eigenvector Research, Inc. 1997-98
%bmw
[mx,nx] = size(x);
tssq = sum(x.^2);
[mx,nl] = size(loads);
vc = zeros(nl,nx);
for i = 1:nl
  pcaest = x*loads(:,i)*loads(:,i)';
  vc(i,:) = 100*sum(pcaest.^2)./tssq;
end
if nargin == 3
  bar(scl,vc','stacked')
  range = max(scl)-min(scl);
  axis([min(scl)-range/nx max(scl)+range/nx 0 100])
else
  bar(vc','stacked')
  axis([0 nx+1 0 100])
end 
set(get(gca,'Children'),'linestyle','none')
xlabel('Variable')
ylabel('Percent Variance Captured')
title(sprintf('Variance Captured for %g PC Model',nl))
