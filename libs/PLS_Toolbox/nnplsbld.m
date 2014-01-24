function [W,Q,P,NEURAL,ssqdif] = nnplsbld(x,y,fac,nosig,plots)
%NNPLSBLD Calculates NNPLS model once structue has been determined
%  This program calculates an NNPLS model for the given x
%  and y blocks and the number of factors, fac, specified, and the number
%  of sigmoids, nosig, for each factor.  It can be used after the NNPLS 
%  model structure has been determined with test set validation. W,Q, and 
%  P are the PLS input and output parameter matrices.  NEURAL contains
%  the weights of the inner neural networks that are constructed.
%  The first row in NEURAL is the number of sigmoids in that factor.  
%  The next entries are the output weights, the input biases, and input 
%  weights. The routine collapse.m is used to calculate the weights
%  in a standard backpropagation neural net from NEURAL. nnplsbld.m also 
%  outputs the fraction of variance captured in the x and y matrices.
%  plots is an optional argument. If plots=1 then plots of the inner  
%  relationships are displayed.  plots=0, or not specified deletes the display.
%  
%  I/O: [W,Q,P,NEURAL,ssqdif] = nnplsbld(x,y,fac,nosig,plots);

%Copyright Thomas Mc Avoy 1994
%Distributed by Eigenvector Research, Inc.
%Modified by BMW 5-8-95

if nargin < 5
  plots = 0;
end
if plots ~= 1
  plots = 0;
end
disp('  ')
if exist('leastsq') == 2
  disp('LEASTSQ from Optimization Toolbox found on search path.')
  disp('Using LEASTSQ for fitting inner relationships.')
else
  disp('LEASTSQ from Optimization Toolbox not found on search path.')
  disp('Using optimization techniques supplied with PLS_Toolbox')
end
disp('  ');
if plots == 1
  disp('Plots option is turned on so routine will pause after each sigmoid')
  disp('is added in each factor. Hit return to continue')
else
  disp('Plot option turned off')
end 
[mx,nx] = size(x);
[my,ny] = size(y);
if nx < fac
  error('No. of LVs must be <= no. of x-block variables')
end; 
Q = zeros(ny,fac);
W = zeros(nx,fac);
NEURAL=zeros(20,fac);
ssq = zeros(fac,2);
ssqx = 0;
for i = 1:nx
  ssqx = ssqx + sum(x(:,i).^2);
end
ssqy = sum(sum(y.^2)');
for i = 1:fac
	[p,q,w,t,u] = plsnipal(x,y);
 	[weights,upred]=nplsbld1(t,u,i,nosig(i),plots);
	n=nosig(i);
% Calculate residuals by subtracting model
  	x = x - t*p';
  	y = y - upred*q';
	beta=weights(1:n+1);
	kin=[weights(n+2:2*n+1)';weights(2*n+2:3*n+1)'];
  	NEURAL(1,i)=n;
  	NEURAL(2:20,i)=weights;
  	ssq(i,1) = (sum(sum(x.^2)'))*100/ssqx;
  	ssq(i,2) = (sum(sum(y.^2)'))*100/ssqy;
  	W(:,i) = w(:,1);
  	Q(:,i) = q(:,1);
	P(:,i)=p(:,1);
end;
ssqdif = zeros(fac,2);
ssqdif(1,1) = 100 - ssq(1,1);
ssqdif(1,2) = 100 - ssq(1,2);
for i = 2:fac
  for j = 1:2
    ssqdif(i,j) = -ssq(i,j) + ssq(i-1,j);
  end
end
ssq = [(1:fac)' ssqdif(:,1) cumsum(ssqdif(:,1)) ssqdif(:,2) ...
 cumsum(ssqdif(:,2))];
disp('  ')
disp('       Percent Variance Captured by PLS Model   ')
disp('  ')
disp('           -----X-Block-----    -----Y-Block-----')
disp('   LV #    This LV    Total     This LV    Total ')
disp('   ----    -------   -------    -------   -------')
format = '   %3.0f     %6.2f    %6.2f     %6.2f    %6.2f';
for i = 1:fac
  tab = sprintf(format,ssq(i,:)); disp(tab)
end
disp('  ')
if exist('leastsq') == 2
  clear global Tscores Uscores
end
hold off
