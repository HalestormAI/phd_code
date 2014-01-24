function [scores,res,tsqvals] = pcapro(newdata,loads,ssq,q,tsq,plots)
%PCAPRO Projects new data on old principal components model.
%  Inputs can be in 2 forms: 1) as a list of input variables
%  or 2) as the single structure variable returned by PCAGUI.
%  1) If a list of input variables is used the inputs are the
%  new data (newdata) scaled the same as the original data,
%  the old loadings (loads), the old variance info (ssq), the
%  limit for Q (reslm), the limit for T^2 (tsqlm) and an optional
%  variable (plots) which suppresses the plots when set to 0.
%
%I/O: [scoresn,resn,tsqn] = pcapro(newdata,loads,ssq,reslm,tsqlm,plots);
%
%   WARNING: Scaling for (newdata) should be the same as original data!
%
%  2) If the PCA model is input as the single structure variable
%  returned by PCAGUI then the inputs are the new data (newdata)
%  in the units of the original data, the structure variable that
%  contains the PCA model (pcamod), and an optional variable (plots)
%  which suppresses the plots when set to 0.
%
%I/O: [scoresn,resn,tsqn] = pcapro(newdata,pcamod,plots);
%
%   NOTE: (newdata) will be scaled in PCAPRO using data contained
%   in (pcamod).
%
%  Outputs are the new scores (scoresn), residuals (resn), and 
%  T^2 values (tsqn). These are plotted if plots ~= 0.
%
%See also: BIGPCA, MODLGUI, MODLPRED, PCA, PCAGUI, PLTLOADS, PLTSCRS,
%          SCRPLTR, SIMCA, RESMTX, TSQMTX, XPLDST

%Copyright Eigenvector Research, Inc. 1991-98
%Modified BMW 11/93, NBG 2/96,2/98,1/99(scaling)

if nargin<=3&nargin>1
  if strcmp(class(loads),'struct')
    if nargin<3
      plots = 1;
    else
      plots = ssq;
    end
    switch loads.scale
    case 'mean'
      newdata = scale(newdata,loads.means);
    case 'auto'
      newdata = scale(newdata,loads.means,loads.stds);
    end
    ssq   = loads.ssq;
    q     = loads.reslim;
    tsq   = loads.tsqlim;
    mo    = loads.samps;
    loads = loads.loads;
  else
    error('Insufficient number of input arguments or pcamod not a structure')
  end
elseif nargin<5
  error('Insufficient number of input arguments')
else
  if nargin < 6
    plots = 1;
  end
end
[m,n]     = size(loads);
[ms,ns]   = size(newdata);
[mss,nss] = size(ssq);
mlimt     = 501;
if ns ~= m
  error('Number of variables in new data not consistent with loadings')
end
scores    = newdata*loads;
scl       = 1:ms;
scllim    = [1 ms];
temp      = [1 1];
if plots ~= 0
  for i = 1:n
    if nargin == 7
      pclim = temp*sqrt(ssq(i,2))*ttestp(.025,mo-i,2);
    else
      pclim = temp*sqrt(ssq(i,2))*1.96;
    end
    plot(scl,scores(:,i),'-r',scllim,pclim,'--b',scllim,-pclim,'--b')
	if ms < mlimt
      hold on, plot(scl,scores(:,i),'+g'), hold off
	end
    xlabel('Sample Number')
	   str = sprintf('Score on PC# %g',i);
    ylabel(str)
    title('New Sample Scores with 95% Limits from Old Model')
    pause
  end
end
if ms > m
  resmat = newdata' - loads*loads'*newdata';
else
  resmat = newdata' - loads*scores';
end
res = (sum(resmat.^2))'; 
lim = [q q];
if plots ~= 0
  plot(scl,res,'-r',scllim,lim,'--b')
  if ms < mlimt
    hold on, plot(scl,res,'+g'), hold off
  end
  title('New Sample Residuals with Limits from Old Model')
  xlabel('Sample Number')
  ylabel('Residual')
  pause
end
if n > 1
  tsqvals = sum((scores.^2*inv(diag(ssq(1:n,2))))')';
else
  tsqvals = (scores.^2*inv(diag(ssq(1:n,2))));
end
if plots ~= 0
  if n == 1
    disp('T^2 not displayed when number of PCs = 1')
  else
    tlim = [tsq tsq];
    plot(scl,tsqvals,'-r',scllim,tlim,'--b')
    if ms < mlimt
      hold on, plot(scl,tsqvals,'+g'), hold off
    end
    title('New Samples Value of T^2 with 95% Limit From Old Model')
    xlabel('Sample Number')
    ylabel('Value of T^2')
  end
end
