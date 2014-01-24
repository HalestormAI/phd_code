function ypred = lwrxy(xnew,xold,yold,lvs,npts,alpha,iter)
%LWRXY Predictions based on lwr models with y-distance weighting
%  This function makes new sample predictions (ypred) for a new
%  matrix of independent variables (xnew) based on an existing 
%  data set of independent (xold) variables and vector of dependent
%  (yold) variables. Predictions are made using a locally weighted
%  regression model defined by the number principal components
%  used to model the independent variables (lvs), the number of
%  points defined as local (npts), the weighting given to the
%  distance in y (alpha) and the number of iterations to use (iter).
%
%Note:  Be sure to use the same scaling on new and old samples!
%
%I/O:  ypred = lwrxy(xnew,xold,yold,lvs,npts,alpha,iter);
%
%See also: LWRDEMO, LWRPRED, NNPLS, PLS, POLYPLS, SPL_PLS

%Copyright Eigenvector Research, Inc. 1994-98

if lvs > npts
  error('npts must >= lvs')
end
[m,n] = size(xnew);
[mold,nold] = size(xold);
if n ~= nold
  error('xnew and xold must have the same number of columns')
end
[axold,mxold] = mncn(xold);
[ayold,myold,stdyold] = auto(yold);
if n < m
  cov = (axold'*axold)/(mold-1);
  [u,s,v] = svd(cov,0);
else
  cov = (axold*axold')/(mold-1);
  [u,s,v] = svd(cov,0);
  v = axold'*v;
  for i = 1:m
    v(:,i) = v(:,i)/norm(v(:,i));
  end
end
u = axold*v(:,1:lvs);
[au,umx,ustd] = auto(u(:,1:lvs));
sxnew = scale(xnew,mxold);
newu = scale(sxnew*v(:,1:lvs),umx,ustd);
ureg = zeros(npts,lvs);
yreg = zeros(npts,1);
weights = zeros(npts,1);
r = u(:,1:lvs)\ayold;
bpcr = (v(:,1:lvs)*r)';
ypred = sxnew*bpcr';
clc
for i = 1:m;
  home
  s = sprintf('Now working on sample %g of %g.',i,m);
  disp(s)
  for k = 1:iter
    xdist = sum(((au-ones(mold,lvs)*diag(newu(i,:))).^2)',1)';
    ydist = (ayold-ones(mold,1)*ypred(i,1)).^2;
	dists = (1-alpha)*xdist + alpha*ydist;
    [a,b] = sort(dists);
    for j = 1:npts
      ureg(j,:) = au(b(j,1),:);
      yreg(j,:) = ayold(b(j,1),1);
      scldist = a(j,1)/a(npts,1);
      weights(j,:) = (1 - scldist^3)^3;
    end
    h = diag(weights.^2);
    ureg1 = [ureg ones(npts,1)];
    breg = inv(ureg1'*h*ureg1)*ureg1'*h*yreg;
    ypred(i,1) = [newu(i,:) 1]*breg;
  end
end
ypred = rescale(ypred,myold,stdyold);
