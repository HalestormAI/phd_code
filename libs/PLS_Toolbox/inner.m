function [x,f0]=inner(n,b,t,u,weights,plots)
%INNER One dimensional nonlinear inner relationship fit for NNPLS
%  Routine to fit a one dimensional nonlinear inner relationship to score data
%  using conjugate gradient optimization.  If the user has the MATLAB toolbox
%  then the leastsq routine can be used in place of the conjugate gradient.
%  n=# of sigmoids, b=pls linear estimate, t,u score vectors
%  The vector x contains the optimized weights, and f0 is optimized 
%  function value.
%
%I/O: [x,f0]=inner(n,b,t,u,weights,plots);

%Copyright Thomas Mc Avoy 1994
%Distributed by Eigenvector Research, Inc.
%Modified by BMW 5-8-95

% The statements below are executed if the Optimization Toolbox routine
% leastsq.m is found on the search path
if exist('leastsq') == 2
  global Tscores Uscores
  Tscores=t;
  Uscores=u;
end
% Lambda is a parameter to penalize large weights	
Lambda=.0002;
% Initialize weights
if n==1
% Every time the algorithm is used, the random seed is reset.  If one
% wants to try different starting points, the statement below can
% be deleted.
  randn('seed',0);
  beta=.1*randn(n+1,1);
  beta(2,1)=1.;
  kin=.1*randn(2,n);
  kin(2,1)=b*2.;
  kin(1,1)=-2*beta(1,1);
% Want first product of beta * kin = b. Others are small random #'s
else
% Initialize with old solution and use random numbers for starting values
% for new sigmoid weights
  beta=.1*randn(n+1,1);
  kin=.1*randn(2,n);
  beta(1:n,1)=weights(1:n);
  kin(1:2,1:n-1)=[weights(n+1:2*n-1)';weights(2*n:3*n-2)'];
end
x0=[beta(:,1);(kin(1,:))';(kin(2,:))'];
% x0 is initial guess for weights
% If the user has the optimization toolbox then the following statements
% are used in place of conjugate gradient routine supplied.
% The options set parameters for Optimization Toolbox. See Optimization
% Toolbox manual. To use leastsq Tscores=t,  and Uscores = u have to be
% added as global variables to inner.m (see grad1.m)
if exist('leastsq') == 2
  options(2)=.001;
  options(3)=.001;
  options(7)=1;
  options(14)=50;
  x=leastsq('fun1',x0,options,'grad1');
else
% cgrdsrch calls a conjugate gradient routine which returns optimized 
% values for weights
  x=cgrdsrch(beta,kin,t,u);
end
beta=x(1:n+1);
kin=[x(n+2:2*n+1)';x(2*n+2:3*n+1)'];
[upred,usig]=bckprpnn(t,kin,beta);
f0=(norm(u-upred))^2+Lambda*(norm(x))^2;
% check for plotting
hold on
if plots==1;
  z = get(gca,'Children');
  if get(z(1),'type') ~= 'text'
    set(z(1),'Visible','off')
  end
  [qq,i]=sort(t);
  for j=1:size(t);
    qqq(j)=upred(i(j));
  end
  plot(qq,qqq,'-r');
  pause
end
hold off


	
	
	
	
	
