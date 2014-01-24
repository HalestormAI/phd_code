function [wts,upred]= nplsbld1(t,u,ii,n,plots)
%NNPLSBLD1 Carries out NNPLS when model structure is already known.
%  A conjugate gradient optimization subroutine is supplied.  If the user
%  has the Optimization Toolbox leastsq.m can be used.  nnpls.m calls 
%  inner.m, and it requires t and u which are the training scores. 
%  nnpls2.m returns the network weights, wts 
%  and the u scores predicted by the inner neural net, upred.
%
%I/O: [wts,upred]= nplsbld1(t,u,ii,n,plots);
%
%Copyright Thomas Mc Avoy 1994

% Calculate linear PLS coefficient to initialize neural net
b=u'*t/(t'*t);
% check for plotting
if plots==1
  clf
  plot(t,b*t)
  hold on		
  s = sprintf('Inner Relationship For Factor %g',ii);
  title(s)
  s = sprintf('Score (t) on X-block Factor %g',ii);
  xlabel(s);
  s = sprintf('Score (u) on Y-block Factor %g',ii);
  ylabel(s); 
  plot(t,u,'oc')
  z = axis; 
  zx1 = z(1)+(z(2)-z(1))*.07;
  zx2 = z(1)+(z(2)-z(1))*.12;
  zy2 = z(3)+(z(4)-z(3))*.93;
  zx3a = z(1)+(z(2)-z(1))*.06;
  zx3b = z(1)+(z(2)-z(1))*.08;
  zy3 = z(3)+(z(4)-z(3))*.88;
  plot(zx1,zy2,'oc')
  plot([zx3a zx3b],[zy3 zy3],'-r')
  text(zx2,zy2,'Training Data')
  text(zx2,zy3,'Inner Relationship Fit')
  pause
end
% Calculate inner model for n sigmoids using optimization
[weights,f0]=inner1(n,b,t,u,weights,plots);
beta=weights(1:n+1);
kin=[weights(n+2:2*n+1)';weights(2*n+2:3*n+1)'];
wts=zeros(19,1);
wts(1:3*n+1,1)=weights(1:3*n+1);
[upred,usig]=bckprpnn(t,kin,beta);


	
	 
	

	


